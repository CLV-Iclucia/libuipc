#pragma once
#include <sim_system.h>
#include <functional>
#include <uipc/common/list.h>
#include <uipc/common/vector.h>
#include <muda/ext/linear_system.h>
#include <linear_system/matrix_converter.h>
#include <linear_system/spmv.h>
namespace uipc::backend::cuda
{
class DiagLinearSubsystem;
class OffDiagLinearSubsystem;
class IterativeSolver;
class LocalPreconditioner;
class GlobalPreconditioner;

class GlobalLinearSystem : public SimSystem
{
    static constexpr SizeT DoFBlockSize = 3;

  public:
    using SimSystem::SimSystem;
    using TripletMatrixView = muda::TripletMatrixView<Float, 3>;
    using CBCOOMatrixView   = muda::CBCOOMatrixView<Float, 3>;
    using DenseVectorView   = muda::DenseVectorView<Float>;
    using CDenseVectorView  = muda::CDenseVectorView<Float>;

    void add_subsystem(DiagLinearSubsystem* subsystem);
    void add_subsystem(OffDiagLinearSubsystem* subsystem,
                       DiagLinearSubsystem*    depend_l,
                       DiagLinearSubsystem*    depend_r);
    void add_solver(IterativeSolver* solver);
    void add_preconditioner(LocalPreconditioner* preconditioner,
                            DiagLinearSubsystem* depend_subsystem);
    void add_preconditioner(GlobalPreconditioner* preconditioner);

    class Impl;

    enum class HessianStorageType
    {
        Full      = 0,
        Symmetric = 1
    };

    class DiagExtentInfo
    {
      public:
        HessianStorageType storage_type() { return m_storage_type; }
        void extent(SizeT hessian_block_count, SizeT dof_count) noexcept;

      private:
        friend class Impl;
        SizeT              m_dof_count    = 0;
        SizeT              m_block_count  = 0;
        HessianStorageType m_storage_type = HessianStorageType::Full;
    };

    class DiagInfo
    {
      public:
        DiagInfo(Impl* impl) noexcept
            : m_impl(impl)
        {
        }

        HessianStorageType storage_type() { return m_storage_type; }
        TripletMatrixView  hessian() { return m_hessian; }
        DenseVectorView    gradient() { return m_gradient; }

      private:
        friend class Impl;
        SizeT              m_index = ~0ull;
        TripletMatrixView  m_hessian;
        DenseVectorView    m_gradient;
        HessianStorageType m_storage_type;
        Impl*              m_impl = nullptr;
    };

    class OffDiagExtentInfo
    {
      public:
        HessianStorageType storage_type() { return m_storage_type; }
        void extent(SizeT lr_hessian_block_count, SizeT rl_hassian_block_count) noexcept;

      private:
        friend class Impl;
        SizeT              m_lr_block_count = 0;
        SizeT              m_rl_block_count = 0;
        HessianStorageType m_storage_type   = HessianStorageType::Full;
    };

    class OffDiagInfo
    {
      public:
        OffDiagInfo(Impl* impl) noexcept
            : m_impl(impl)
        {
        }

        HessianStorageType storage_type() { return m_storage_type; }
        TripletMatrixView  lr_hessian() { return m_lr_hessian; }
        TripletMatrixView  rl_hessian() { return m_rl_hessian; }

      private:
        friend class Impl;
        SizeT              m_index = ~0ull;
        TripletMatrixView  m_lr_hessian;
        TripletMatrixView  m_rl_hessian;
        HessianStorageType m_storage_type;
        Impl*              m_impl = nullptr;
    };

    class GlobalPreconditionerAssemblyInfo
    {
      public:
        GlobalPreconditionerAssemblyInfo(Impl* impl) noexcept
            : m_impl(impl)
        {
        }

        CBCOOMatrixView    A() { return m_A; }
        HessianStorageType storage_type() { return m_storage_type; }

      private:
        friend class Impl;
        CBCOOMatrixView    m_A;
        bool               symmetric = false;
        Impl*              m_impl    = nullptr;
        HessianStorageType m_storage_type;
    };

    class LocalPreconditionerAssemblyInfo
    {
      public:
        LocalPreconditionerAssemblyInfo(Impl* impl) noexcept
            : m_impl(impl)
        {
        }

      private:
        friend class Impl;
        SizeT m_index = ~0ull;
        Impl* m_impl  = nullptr;
    };

    class ApplyPreconditionerInfo
    {
      public:
        ApplyPreconditionerInfo(Impl* impl) noexcept
            : m_impl(impl)
        {
        }

        DenseVectorView  z() { return m_z; }
        CDenseVectorView r() { return m_r; }

      private:
        friend class Impl;
        DenseVectorView  m_z;
        CDenseVectorView m_r;
        Impl*            m_impl = nullptr;
    };

    class AccuracyInfo
    {
      public:
        AccuracyInfo(Impl* impl) noexcept
            : m_impl(impl)
        {
        }

        CDenseVectorView r() { return m_r; }

        void statisfied(bool statisfied) { m_statisfied = statisfied; }

      private:
        friend class Impl;
        CDenseVectorView m_r;
        Impl*            m_impl       = nullptr;
        bool             m_statisfied = true;
    };

    class SolvingInfo
    {
      public:
        SolvingInfo(Impl* impl)
            : m_impl(impl)
        {
        }

        DenseVectorView  x() { return m_x; }
        CDenseVectorView b() { return m_b; }
        void iter_count(SizeT iter_count) { m_iter_count = iter_count; }

      private:
        friend class Impl;
        DenseVectorView  m_x;
        CDenseVectorView m_b;
        SizeT            m_iter_count = 0;
        Impl*            m_impl       = nullptr;
    };

    class SolutionInfo
    {
      public:
        SolutionInfo(Impl* impl)
            : m_impl(impl)
        {
        }

        CDenseVectorView solution() { return m_solution; }

      private:
        friend class Impl;
        CDenseVectorView m_solution;
        Impl*            m_impl = nullptr;
    };

  private:
    class LinearSubsytemInfo
    {
      public:
        bool  is_diag     = false;
        SizeT local_index = ~0ull;
        SizeT index       = ~0ull;
    };

  public:
    class Impl
    {
      public:
        void init();

        void build_linear_system();
        bool _update_subsystem_extent();
        void _assemble_linear_system();
        void _assemble_preconditioner();
        void solve_linear_system();
        void distribute_solution();

        Float reserve_ratio = 1.5;

        // Core Invariant Data
        vector<LinearSubsytemInfo> subsystem_infos;
        vector<SizeT>              subsystem_triplet_offsets;
        vector<SizeT>              subsystem_triplet_counts;
        vector<ulonglong2>         off_diag_lr_triplet_counts;
        vector<SizeT>              diag_dof_offsets;
        vector<SizeT>              diag_dof_counts;
        vector<int>                accuracy_statisfied_flags;

        // Buffer
        list<DiagLinearSubsystem*>    diag_subsystem_buffer;
        list<OffDiagLinearSubsystem*> off_diag_subsystem_buffer;
        list<LocalPreconditioner*>    local_preconditioner_buffer;

        // Containers
        vector<DiagLinearSubsystem*>    diag_subsystems;
        vector<OffDiagLinearSubsystem*> off_diag_subsystems;
        vector<LocalPreconditioner*>    local_preconditioners;

        IterativeSolver*      iterative_solver      = nullptr;
        GlobalPreconditioner* global_preconditioner = nullptr;

        // Linear System
        muda::LinearSystemContext           ctx;
        muda::DeviceDenseVector<Float>      x;
        muda::DeviceDenseVector<Float>      b;
        muda::DeviceTripletMatrix<Float, 3> triplet_A;
        muda::DeviceBCOOMatrix<Float, 3>    bcoo_A;
        muda::DeviceBSRMatrix<Float, 3>     bsr_A;
        muda::DeviceCSRMatrix<Float>        csr_A;

        Spmv            spmver;
        MatrixConverter converter;

        bool empty_system = true;

        void apply_preconditioner(muda::DenseVectorView<Float>  z,
                                  muda::CDenseVectorView<Float> r);

        void spmv(Float a, muda::CDenseVectorView<Float> x, Float b, muda::DenseVectorView<Float> y);

        bool accuracy_statisfied(muda::DenseVectorView<Float> r);
    };

  protected:
    void do_build() override;

  private:
    friend class SimEngine;
    friend class IterativeSolver;

    void solve();
    Impl m_impl;
};
}  // namespace uipc::backend::cuda