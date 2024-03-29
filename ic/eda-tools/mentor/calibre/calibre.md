
# calibre

doc: firefox docs/index.html -> Physical Verification

* 新用户手册: **Calibre Interactive Users's Manual**
* 旧用户手册: **Calibre Interactive (Classic GUI) Users's Manual**

搜索时勾选 **Exact Match** 和 **Search within topic heading only**

[SVRF](./svrf.md)

## summary

设置calibre版本

```csh
# 设置环境变量，不能通过修改可执行程序指定版本
# 设置的路径下一级就有bin目录
setenv CALIBRE_HOME /eda-tools/mentor/calibre202104/aoj_cal_2021.4_25
setenv MGC_HOME $CALIBRE_HOME
```

## DRC/LVS/ERC

```bash
# <runset_file>一般由芯片制造商提供

# DRC
calibre -drc -hier <runset_file>

# LVS(ERC)
calibre -lvs -hier -spice lay.net -turbo 4 <runset_file>
```

查看drc检查结果

```text
Calibre 进行 DRC 检查后，可以通过查看生成的 DRC 摘要报告文件来了解检查的结果。DRC 摘要报告文件通常是一个具有 ".sum" 扩展名的 ASCII 文本文件。
若存在 DRC 失败情况，DRC 摘要报告文件中对应的规则数目将会被标记为非零值，若无 DRC 失败情况，则所有规则的出现次数都为零。
然后可在 ".rep" 和将标准输出重定到的日志文件中查看更多细节。
```

使用gui查看检查结果

```text
1. calibre -gui 打开界面
2. 选择 RVE
3. Database选择 .rep 文件，点击 Open 按钮
```

## LVL

[知乎](https://zhuanlan.zhihu.com/p/148105306)

```bash
# 指定 -resultformat ASCII 时导出 ascii 格式文件，不指定时导出 gds
dbdiff -refsystem GDS -system GDS -refdesign top_ref.gds top_cell -design top.gds chip_top -write_xor_rules xor.rul diff -resultformat ASCII
calibre -drc -hier -turbo -hyper -fx xor.rul | tee xor.log &
```

参数：
-turbo <number_of_processors>
-turbo_all

## runset

* 搜索 **Option Descriptions** 查看更多设置描述信息

### 特殊名称含义

搜索: Templates For File Naming

```txt
%l  : layout primary cell name
%s  : source primary cell name
%L  : layout library name
%V  : layout view name
%S  : source library name
%W  : source view name
```

### DRC检查

DRC 检查只会对设置为 **LAYOUT PRIMARY** 的 cell 进行检查，虽然支持 **通配符** ，但只会检查首个匹配的 cell，在指定 -hier 的情况下，会检查top cell 的子 cell

```sh
# 在界面中创建及加载
创建: 在界面做好相应设置 -> File -> Save Runset As -> 保存到指定位置
加载: File -> Load Runset

# 通过环境变量设置
setenv MGC_CALIBRE_DRC_RUNSET_FILE $runset_file

# 直接指定
calibre -reset $runset_file
calibre -reset "$runset_file $runset_file2"
```

## 自定义界面

自定义界面，会显示在 calibre 界面中，可以在其中自定义一些控件，然后根据控件的值修改默认值

* 方式一: 使用 tcl 语法的 custom-file
* 方式二: 使用 javascript 语法的 configuration

命令/函数文档

```txt
新用户手册章节: GUI Customization for Calibre Interactive
旧用户手册章节: Customization Files
```

```sh
# 通过环境变量设置
setenv MGC_CALIBRE_CUSTOMIZATION_FILE $custom_file

# 直接指定，优先级高于环境变量
calibre -gui -drc -custom $custom_file
```

### custom 命令示例

```tcl
# 不支持行内注释

# 窗口尺寸
CUSTOM::SETWINGEOM 730x600
# 添加 label
CUSTOM::LABEL -prompt "DRC Settings" -tool DRC

# 创建 label + 输入框，并赋值给变量，后续通过变量获取文本值
set tech_obj [CUSTOM::VARIABLE -name TECHDIR -prompt "Label-Name" -tool DRC -initval "default-value"]

# 创建勾选框
set sel_obj [CUSTOM::DEFINE -name SEL -prompt "Select-Box" -tool DRC -boolean 1 -select 0]
# 创建多选框
set choice_obj [CUSTOM::DEFINE -name BATCH -prompt "Batch-Mode" -tool DRC -choices {YES NO} -boolean 0]

# 分割线
CUSTOM::SEPARATOR -tool DRC

# 设置确定按钮回调
proc ok_callback {} {
    global tech_obj
    global sel_obj
    global choice_obj

    # 值为文本框内字符串
    set techStr     [set [$tech_obj cget -cvar]]
    # 勾选值为 1，否则为 0
    set selStr      [set [$sel_obj cget -bvar]]
    # 值为选中的字符串
    set choiceStr   [set [$choice_obj cget -bvar]]
    # set env(TECHDIR) $techStr
    puts "TECHDIR: $techStr, SEL: $selStr, CHOICE: $choiceStr"
}
CUSTOM::setOKCallback ok_callback
```

### 获取/修改 runset 值

runset name 是 calibre 内部定义好的一些字段，对应自带界面控件
搜索 **Option Descriptions** 查看含义及对应关系

```tcl
# 获取 runset 值
set top_cell [CUSTOM::getRunsetVarValue drcLayoutPrimary]

# 设置 runset 值
CUSTOM::setRunsetVarValue drcLayoutPrimary "TEST"
```
