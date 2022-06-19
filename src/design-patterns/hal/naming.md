# 命名


<a id="c-crate-name"></a>
## crate被恰当地命名(C-CRATE-NAME)

HAL crates应该在它目标支持的芯片或者芯片家族之后被命名。它们的名字应该以`-hal`结尾，为了将它们与寄存器访问crates区分开来。名字不应该包含下划线(请改用破折号)。
