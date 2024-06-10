#pragma once
#include <uipc/common/type_define.h>
#include <string_view>
#define READABLE_TYPE_NAME_AS_ALIAS(type)                                      \
    template <>                                                                \
    constexpr std::string_view readable_type_name<type>() noexcept             \
    {                                                                          \
        return #type;                                                          \
    }

namespace uipc
{
template <typename T>
constexpr std::string_view readable_type_name() noexcept
{
    return typeid(T).name();
}


READABLE_TYPE_NAME_AS_ALIAS(Vector2);
READABLE_TYPE_NAME_AS_ALIAS(Vector3);
READABLE_TYPE_NAME_AS_ALIAS(Vector4);

READABLE_TYPE_NAME_AS_ALIAS(Vector2i);
READABLE_TYPE_NAME_AS_ALIAS(Vector3i);
READABLE_TYPE_NAME_AS_ALIAS(Vector4i);

READABLE_TYPE_NAME_AS_ALIAS(Vector6);
READABLE_TYPE_NAME_AS_ALIAS(Vector9);
READABLE_TYPE_NAME_AS_ALIAS(Vector12);

READABLE_TYPE_NAME_AS_ALIAS(Matrix2x2);
READABLE_TYPE_NAME_AS_ALIAS(Matrix3x3);
READABLE_TYPE_NAME_AS_ALIAS(Matrix4x4);

READABLE_TYPE_NAME_AS_ALIAS(Matrix6x6);
READABLE_TYPE_NAME_AS_ALIAS(Matrix9x9);
READABLE_TYPE_NAME_AS_ALIAS(Matrix12x12);


}  // namespace uipc

#undef READABLE_TYPE_NAME_AS_ALIAS