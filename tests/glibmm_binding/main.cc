#include <glib.h>
#include <glibmm/binding.h>
#include <glibmm/init.h>
#include <glibmm/object.h>
#include <glibmm/property.h>
#include <glibmm/propertyproxy.h>

#include <algorithm>
#include <limits>

namespace {

class StringSource final: public Glib::Object {
public:
  StringSource(): Glib::ObjectBase{"StringSource"} {}
  auto property_string() { return m_property_string.get_proxy(); }

private:
  Glib::Property<Glib::ustring> m_property_string{*this, "string"};
};

class IntTarget final: public Glib::Object {
public:
  IntTarget(): Glib::ObjectBase{"IntTarget"} {}
  auto property_int() { return m_property_int.get_proxy(); }

private:
  Glib::Property<int> m_property_int{*this, "int"};
};

auto
transform_string_to_int(const Glib::ustring& source) -> std::optional<int>
{
  char* str_end{};
  auto long_int = std::strtol(source.c_str(), &str_end, 10);

  if (str_end == source.c_str())
    return std::nullopt;

  using IntLimits = std::numeric_limits<int>;
  auto constexpr min = long{IntLimits::min()};
  auto constexpr max = long{IntLimits::max()};
  auto const clamped_int = std::clamp(long_int, min, max);

  if (clamped_int != long_int)
    return std::nullopt;

  return static_cast<int>(clamped_int);
}

void
test()
{
  Glib::init();

  auto source = StringSource{};
  auto target = IntTarget{};

  auto create_binding = [&source, &target](Glib::Binding::Flags flags)
  {
    return Glib::Binding::bind_property(
      source.property_string(), target.property_int(),
      flags, &transform_string_to_int);
  };

  // We should obviously not change the target before it has been bound!
  target.property_int() = 7;
  source.property_string() = "42";
  g_assert_cmpint(target.property_int(), ==, 7);

  {
    auto binding = create_binding(Glib::Binding::Flags::DEFAULT);

    // Without SYNC_CREATE, only changes after bound will be synced
    g_assert_cmpint(target.property_int(), ==, 7);

    // An empty string is not a zero
    source.property_string() = "";
    g_assert_cmpint(target.property_int(), ==, 7);

    // Ensure the change is synced
    source.property_string() = "47";
    g_assert_cmpint(target.property_int(), ==, 47);

    // Ensure no change when invalid source results in false return
    source.property_string() = "six six six";
    g_assert_cmpint(target.property_int(), ==, 47);

    // or when we manually unbind
    binding->unbind();
    source.property_string() = "666";
    g_assert_cmpint(target.property_int(), ==, 47);
  }

  // Ensure the binding was released when its RefPtr went out of scope
  source.property_string() = "89";
  g_assert_cmpint(target.property_int(), ==, 47);

  {
    auto binding = create_binding(Glib::Binding::Flags::SYNC_CREATE);

    // With SYNC_CREATE, value of source must sync to target on bind
    g_assert_cmpint(target.property_int(), ==, 89);
  }

  // Ensure the binding was released when its RefPtr went out of scope
  source.property_string() = "97";
  g_assert_cmpint(target.property_int(), ==, 89);

  // Ensure that a manage()d binding...
  {
    auto binding = create_binding(Glib::Binding::Flags::DEFAULT);
    Glib::manage(binding);

    // (a) still syncs when the source value changes
    source.property_string() = "1999";
    g_assert_cmpint(target.property_int(), ==, 1999);
  }

  // and (b) still binds the properties after our RefPtr to it goes out of scope
  source.property_string() = "2001";
  g_assert_cmpint(target.property_int(), ==, 2001);
}

} // namespace

auto
main() -> int
{
  test();
  return 0;
}
