#include <sim_engine.h>
#include <uipc/common/range.h>
#include <dof_predictor.h>
#include <global_geometry/global_vertex_manager.h>
#include <global_geometry/global_simplicial_surface_manager.h>
#include <contact_system/global_contact_manager.h>
#include <collision_detection/global_trajectory_filter.h>
#include <line_search/line_searcher.h>
#include <gradient_hessian_computer.h>
#include <linear_system/global_linear_system.h>
#include <animator/global_animator.h>


namespace uipc::backend::cuda
{
void SimEngine::do_advance()
{
    Float alpha     = 1.0;
    Float ccd_alpha = 1.0;
    Float cfl_alpha = 1.0;

    /***************************************************************************************
    *                                  Function Shortcuts
    ***************************************************************************************/

    auto detect_dcd_candidates = [this]
    {
        if(m_global_trajectory_filter)
        {
            m_global_trajectory_filter->detect(0.0);
            m_global_trajectory_filter->filter_active();
        }
    };

    auto detect_trajectory_candidates = [this](Float alpha)
    {
        if(m_global_trajectory_filter)
        {
            m_global_trajectory_filter->detect(alpha);
        }
    };

    auto filter_dcd_candidates = [this]
    {
        if(m_global_trajectory_filter)
        {
            m_global_trajectory_filter->filter_active();
        }
    };

    auto record_friction_candidates = [this]
    {
        if(m_global_trajectory_filter && m_friction_enabled)
        {
            m_global_trajectory_filter->record_friction_candidates();
        }
    };

    auto compute_adaptive_kappa = [this]
    {
        // TODO: now no effect
        if(m_global_contact_manager)
            m_global_contact_manager->compute_adaptive_kappa();
    };

    auto compute_contact = [this]
    {
        if(m_global_contact_manager)
            m_global_contact_manager->compute_contact();
    };

    auto cfl_condition = [&cfl_alpha, this](Float alpha)
    {
        if(m_global_contact_manager)
        {
            cfl_alpha = m_global_contact_manager->compute_cfl_condition();
            if(cfl_alpha < alpha)
            {
                spdlog::info("CFL Filter: {} < {}", cfl_alpha, alpha);
                return cfl_alpha;
            }
        }

        return alpha;
    };

    auto filter_toi = [&ccd_alpha, this](Float alpha)
    {
        if(m_global_trajectory_filter)
        {
            ccd_alpha = m_global_trajectory_filter->filter_toi(alpha);
            if(ccd_alpha < alpha)
            {
                spdlog::info("CCD Filter: {} < {}", ccd_alpha, alpha);
                return ccd_alpha;
            }
        }

        return alpha;
    };

    auto compute_energy = [this, filter_dcd_candidates](Float alpha) -> Float
    {
        // Step Forward => x = x_0 + alpha * dx
        m_global_vertex_manager->step_forward(alpha);
        m_line_searcher->step_forward(alpha);

        // Update the collision pairs
        filter_dcd_candidates();

        // Compute New Energy => E
        return m_line_searcher->compute_energy(false);
    };

    auto step_animation = [this]()
    {
        if(m_global_animator)
            m_global_animator->step();
    };

    auto compute_animation_substep_ratio = [this](SizeT newton_iter)
    {
        // compute the ratio to the aim position.
        // dst = prev_position + ratio * (position - prev_position)
        if(m_global_animator)
        {
            m_global_animator->compute_substep_ratio(newton_iter);
            spdlog::info("Animation Substep Ratio: {}", m_global_animator->substep_ratio());
        }
    };

    auto animation_reach_target = [this]()
    {
        if(m_global_animator)
        {
            return m_global_animator->substep_ratio() >= 1.0;
        }
        return true;
    };

    /***************************************************************************************
    *                                  Core Pipeline
    ***************************************************************************************/

    // Abort on exception if the runtime check is enabled for debugging
    constexpr bool AbortOnException = uipc::RUNTIME_CHECK;

    auto pipeline = [&]() noexcept(AbortOnException)
    {
        Timer timer{"Pipeline"};

        ++m_current_frame;

        spdlog::info(R"(>>> Begin Frame: {})", m_current_frame);

        // Rebuild Scene (No effect now)
        {
            Timer timer{"Rebuild Scene"};
            // Trigger the rebuild_scene event, systems register their actions will be called here
            m_state = SimEngineState::RebuildScene;
            {
                event_rebuild_scene();

                // TODO: rebuild the vertex and surface info
                // m_global_vertex_manager->rebuild_vertex_info();
                // m_global_surface_manager->rebuild_surface_info();
            }

            // After the rebuild_scene event, the pending creation or deletion can be solved
            world().scene().solve_pending();
        }

        // Simulation:
        {
            Timer timer{"Simulation"};
            // 1. Adaptive Parameter Calculation
            AABB vertex_bounding_box =
                m_global_vertex_manager->compute_vertex_bounding_box();
            detect_dcd_candidates();
            compute_adaptive_kappa();

            // 2. Record Friction Candidates at the beginning of the frame
            record_friction_candidates();

            // 3. Predict Motion => x_tilde = x + v * dt
            m_state = SimEngineState::PredictMotion;
            m_dof_predictor->predict();
            step_animation();

            // 4. Nonlinear-Newton Iteration
            Float box_size = vertex_bounding_box.diagonal().norm();
            Float tol      = m_newton_scene_tol * box_size;
            Float res0     = 0.0;

            for(auto&& newton_iter : range(m_newton_max_iter))
            {
                Timer timer{"Newton Iteration"};

                // 1) Compute animation substep ratio
                compute_animation_substep_ratio(newton_iter);

                // 2) Build Collision Pairs
                if(newton_iter > 0)
                    detect_dcd_candidates();

                // 3) Compute Contact Gradient and Hessian => G:Vector3, H:Matrix3x3
                m_state = SimEngineState::ComputeContact;
                {
                    Timer timer{"Compute Contact"};
                    compute_contact();
                }

                // 4) Compute System Gradient and Hessian
                m_state = SimEngineState::ComputeGradientHessian;
                {
                    Timer timer{"Compute Gradient Hessian"};
                    m_gradient_hessian_computer->compute_gradient_hessian();
                }

                // 5) Solve Global Linear System => dx = A^-1 * b
                m_state = SimEngineState::SolveGlobalLinearSystem;
                {
                    Timer timer{"Solve Global Linear System"};
                    m_global_linear_system->solve();
                }


                // 6) Get Max Movement => dx_max = max(|dx|), if dx_max < tol, break
                m_global_vertex_manager->collect_vertex_displacements();
                Float res = m_global_vertex_manager->compute_axis_max_displacement();

                // 7) Check Termination Condition
                // TODO: Maybe we can implement a class for termination condition in the future
                bool converged = false;
                {
                    if(newton_iter == 0)
                        res0 = res;  // record the initial residual

                    Float rel_tol = res == 0.0 ? 0.0 : res / res0;

                    spdlog::info(">> Frame {} Newton Iteration {} => Residual/AbsTol/RelTol: {}/{}/{}",
                                 m_current_frame,
                                 newton_iter,
                                 res,
                                 m_abs_tol,
                                 rel_tol);


                    converged = res <= m_abs_tol || rel_tol <= 0.001;

                    if(newton_iter > 0 && converged && animation_reach_target())
                        break;
                }


                // 8) Begin Line Search
                m_state = SimEngineState::LineSearch;
                {
                    Timer timer{"Line Search"};

                    // Reset Alpha
                    alpha = 1.0;

                    // Record Current State x to x_0
                    m_line_searcher->record_start_point();
                    m_global_vertex_manager->record_start_point();
                    detect_trajectory_candidates(alpha);

                    // Compute Current Energy => E_0
                    Float E0 = m_line_searcher->compute_energy(true);  // initial energy
                    // spdlog::info("Initial Energy: {}", E0);

                    // CCD filter
                    alpha = filter_toi(alpha);

                    // CFL Condition
                    alpha = cfl_condition(alpha);

                    // Compute Test Energy => E
                    Float E  = compute_energy(alpha);
                    Float E1 = E;

                    if(!converged)
                    {
                        SizeT line_search_iter = 0;
                        while(line_search_iter++ < m_line_searcher->max_iter())
                        {
                            Timer timer{"Line Search Iteration"};

                            bool energy_decrease = E <= E0;  // Check Energy Decrease

                            // TODO: Inversion Check (Not Implemented Yet)
                            bool no_inversion = true;

                            bool success = energy_decrease && no_inversion;
                            if(success)
                                break;

                            // If not success, then shrink alpha
                            alpha /= 2;
                            E = compute_energy(alpha);
                        }

                        if(line_search_iter >= m_line_searcher->max_iter())
                        {
                            //m_global_linear_system->dump_linear_system(
                            //    fmt::format("{}.{}.{}", workspace(), frame(), newton_iter));

                            spdlog::warn(
                                "Line Search Exits with Max Iteration: {} (Frame={}, Newton={})\n"
                                "E/E0: {}, E1/E0: {}, E0:{}",
                                m_line_searcher->max_iter(),
                                m_current_frame,
                                newton_iter,
                                E / E0,
                                E1 / E0,
                                E0);
                        }
                    }
                }
            }

            // 5. Update Velocity => v = (x - x_0) / dt
            m_state = SimEngineState::UpdateVelocity;
            m_dof_predictor->compute_velocity();
            m_global_vertex_manager->record_prev_positions();
        }

        spdlog::info("<<< End Frame: {}", m_current_frame);
    };

    try
    {
        pipeline();
    }
    catch(const SimEngineException& e)
    {
        spdlog::error("Simulation Engine Exception: {}", e.what());
    }
}
}  // namespace uipc::backend::cuda