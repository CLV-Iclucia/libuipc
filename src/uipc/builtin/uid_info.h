#pragma once
#include <uipc/common/macro.h>
#include <uipc/common/type_define.h>
#include <uipc/common/string.h>

namespace uipc::builtin
{
struct UIPC_CORE_API UIDInfo
{
    static constexpr U64 OfficialBuiltinUIDStart = 0;
    static constexpr U64 UserDefinedUIDStart     = 1ull << 32;

    U64    uid;
    string name;
    string author;
    string email;
    string website;
    string description;

    bool is_official_builtin_uid(U64 uid) const noexcept;

    bool is_user_defined_uid(U64 uid) const noexcept;
};
}  // namespace uipc::builtin
