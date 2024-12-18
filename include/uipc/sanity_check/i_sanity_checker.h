#pragma once
#include <uipc/common/dllexport.h>
#include <uipc/common/type_define.h>

namespace uipc::core
{
class Scene;

enum class SanityCheckResult : int
{
    Success = 0,
    Warning = 1,
    Error   = 2
};

class UIPC_CORE_API ISanityChecker
{
  public:
    virtual ~ISanityChecker() = default;
    U64               id() const noexcept;
    SanityCheckResult check() noexcept;

  protected:
    virtual U64               get_id() const noexcept = 0;
    virtual SanityCheckResult do_check() noexcept     = 0;
};
}  // namespace uipc::core
