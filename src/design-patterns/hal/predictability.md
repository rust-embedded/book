# 可预见性


<a id="c-ctor"></a>
## 使用构造函数而不是扩展traits

所有由HAL添加功能的外设应该被封装进一个新类型，即使该功能不需要额外的字段。

应该避免为原始外设扩展traits。

<a id="c-inline"></a>
## 方法在适当的地方用`#[inline`修饰

The Rust compiler does not by default perform full inlining across crate
boundaries. As embedded applications are sensitive to unexpected code size
increases, `#[inline]` should be used to guide the compiler as follows:

* All "small" functions should be marked `#[inline]`. What qualifies as "small"
  is subjective, but generally all functions that are expected to compile down
  to single-digit instruction sequences qualify as small.
* Functions that are very likely to take constant values as parameters should be
  marked as `#[inline]`. This enables the compiler to compute even complicated
  initialization logic at compile time, provided the function inputs are known.
