
# virtuoso

## 启动

```sh
# 需要在启动目录下有 cds.lib 文件定义库配置
bsub virtuoso

# 初始化执行自定义代码(skill)
echo 'cmd' >> ~/.cdsinit

# Tools -> Library Manager 打开库管理器
```

## 主窗口

打开 virtuoso 后的窗口，可以在下方命令行执行 skill 命令，可以使用 shell 的 **快捷跳转**，如 ctrl-A 跳到行首

菜单栏

* File: 导入导出 view
* Tools: library管理器，skill函数查找窗口，skill IDE
* Options: 快捷键，日志等级

### 快捷键

查看快捷键对应函数: Options -> BindKeys

```text
shift + S: 查找, search for选项选择查找类型
k        : 测量距离
f        : 自动缩放当前版图为合适大小
shift + f: 有多个 cell 时显示 cell 内部结构
```

### 日志等级

Options -> Log Filter

全部勾选查看更多日志

### 导入view

```text
gds: File -> Import -> Stream
    Stream File: 要导入的gds文件
    Library: 要导入到哪个库
    Technology->Attach Tech Library: 相关tech库，一般在cds.lib中会设置好

cdl: File -> Import -> Spice
    Input:
        Netlist File: 要导入的cdl网表
        Netlist Language: 网表类型
        Reference Library List: 引用了哪些库, 空格分割（cdl中可能引用了其他库中定义的网表）
    Output:
        Output Library: 要导入到哪个库
```

### 导出view

[命令导出gds](./cadence.md#导出gds)
[命令导出cdl](./cadence.md#导出cdl)
[命令导出lef](./cadence.md#导出lef)

```text
gds: File -> Export -> Stream
    Stream File: 要导出的gds文件
```

## 自定义菜单栏

在 ~/.cdsinit 中 load /path/[custom_menu.il](./scripts/custom_menu.il)

添加自定义 layout/schematic 菜单栏

## Layout 窗口

最下方状态栏显示三项：

* 鼠标
* 回调函数(skill)
* TODO

## SKILL

[skill](./skill/skill.md)

## Debug

### 命令

在 CIW 中执行命令出现 error 时会进入 debug 模式
通过 help debug 查看可以使用哪些函数来 debug

### SKILL IDE

在 SKILL IDE 中执行代码可以设置断点并根据界面提供的控制按钮进行操作

### 函数调用堆栈

```skill
tracef('t)          ; 开启
untrace()           ; 关闭
```

## 执行 skill 脚本
