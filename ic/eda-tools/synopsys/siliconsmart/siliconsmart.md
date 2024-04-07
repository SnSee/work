
# siliconsmart

文档: doc/html/index.html，搜索关键字

## qualify_library

[介绍](https://blog.eetop.cn/blog-565339-6944738.html)

## K 库

[整体介绍](https://bbs.eetop.cn/thread-876237-1-1.html)

[命令介绍](https://bbs.eetop.cn/thread-876874-1-1.html)

### 命令

#### configure

为 characterize 创建环境

```tcl
configure -timing -power -ccs -lvf $cells
```

#### characterize

为指定 cell 做 timing, power 仿真

```tcl
characterize $cells
```

#### model

基于 characterize 结果生成 view

```tcl
model -timing -power -verilog
```

### 步骤

#### 创建 workspace

```tcl
# -legacy: 生成默认的 configure.tcl，根据帮助文档中的提示进行修改
# 也可以借助 import 命令提取 .lib .spice 中信息生成 configure.tcl
create -clean char_dir     # 创建 k库 目录结构
```

#### 修改 configure.tcl

```tcl
# 定义 pin 类型对应属性设置，供后续 add_pin 使用
pintype default {
    set logic_high_name VDD
    set logic_high_threshold 0.9
    ...
}

# Operating Conditions(PVT)
create_operating_condition best_pvt
set_opc_process best_pvt {
    # SPICE 信息
    {.lib "/tmp/process.lib" FF}
    {.lib "/tmp/process.lib" FF_3V}
}
add_opc_supplies best_pvt VSS 0.0 VDD 1.1 VDD3 3.63
set_opc_temperature best_pvt 0
# 设置使用的 PVT
set active_pvts {best_pvt}
```

#### 导入 cell

从 .lib，netlist 或已经存在的 char_dir 导入 cell

```tcl
import -liberty test.lib -netlist test.spice -overwrite -configure -state_independent -use_default_slews -use_default_loads -use_default_whens $cells
```

#### 创建 instance

```tcl
set_nestlist_file [get_location]/netlists/test.cir

# 定义 pin
add_pin {A[0:2]} default -input
add_pin {B C D} default -input
add_pin Z default -output
add_pin VDD default -inout -supply

add_function Z A

# 配置
# state_partitions option
set_config_opt -type timing state_partitions none
set_config_opt -type constraint state_partitions none
set_config_opt -type mpw state_partitions none
set_config_opt -type energy state_partitions none
set_config_opt -type leakage_power state_partitions none
set_config_opt -type noise state_partitions one
set_config_opt -type leakage_power state_partitions one
set_config_opt -type { noise timing } -from A -to Z
state_partitions one

# timing when condition
# combinational(组合逻辑)
set_config_opt -type {timing} -cell SDFFRPQ -from B0 -to Y default_arc_whens { !A0 }
set_config_opt -type {timing} -cell SDFFRPQ -from B0 -to Y -- whens {A0 !A0 {B1 | B2}}
# 时序逻辑
set_config_opt -type {setup hold} -cell SDFFRPQ -from SE -reference CK default_arc_whens {SI}

# slew/load
set explicit_points_slew { 0.1e-9 0.2e-9 0.3e-9 0.4e-9 0.5e-9 }

# threshold
logic_low_threshold_fall    0.25
logic_high_threshold_fall   0.55
logic_low_threshold_rise    0.25
logic_high_threshold_rise   0.55
```

#### 开始仿真

```tcl
characterize $cells
```
