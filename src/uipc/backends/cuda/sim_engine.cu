#include <sim_engine.h>
#include <uipc/backends/module.h>
#include <uipc/common/log.h>
#include <muda/muda.h>
#include <kernel_cout.h>
#include <sim_engine_device_common.h>
#include <log_pattern_guard.h>
#include <sim_system_collection.h>

namespace uipc::backend::cuda
{
void say_hello_from_muda()
{
    using namespace muda;

    Launch()
        .apply([] __device__()
               { cout << "Hello from CudaEngine CUDA Kernel!\n"; })
        .wait();
}

SimEngine::SimEngine()
    : m_device_impl(make_unique<DeviceImpl>())
{
    LogGuard guard;

    spdlog::info("Cuda Backend Init Success.");

    using namespace muda;

    auto viewer_ptr       = device_logger_viewer_ptr();
    m_device_impl->logger = make_unique<muda::Logger>(viewer_ptr);

    Debug::set_sync_callback(
        [this]
        {
            m_string_stream.str("");
            m_device_impl->logger->retrieve(m_string_stream);
            if(m_string_stream.str().empty())
                return;

            std::string str = m_string_stream.str();
            spdlog::info(R"([Kernel Console] 
-------------------------------------------------------------------------------
{}
-------------------------------------------------------------------------------)",
                         str);
        });

    say_hello_from_muda();
}

SimEngine::~SimEngine()
{
    LogGuard guard;

    muda::wait_device();

    // remove the sync callback
    muda::Debug::set_sync_callback(nullptr);

    spdlog::info("Cuda Backend Shutdown Success.");
}

auto SimEngine::device_impl() noexcept -> DeviceImpl&
{
    return *m_device_impl;
}
}  // namespace uipc::backend::cuda
