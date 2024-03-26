
# icc2

帮助文档: doc/LM/man/htmlView

```text
command: 命令文档
message: info/error 编号文档
shell  : icc2_lm_shell 命令文档
```

在界面操作时会在终端显示主要的的 tcl 命令，同时在 **lm_command.log** 文件中会记录所有命令

## icc2基本用法(tcl语法)

### 查看 ndm

```sh
# 命令行方式
icc2_lm_shell
open_lib test       # test是目录，下面要有 reflib.ndm

# 打开界面
icc2_lm_shell -gui
```

### 命令

获取lib名称列表，默认为所有已经open的lib

```tcl
set lib_names [get_libs $name_wildcard]
```

获取cell名称列表，默认为所有cell

```tcl
set frame_name [get_lib_cells -include_sub_cells $lib_name/$cell_name/frame]
set timing_name [get_lib_cells -include_sub_cells $lib_name/$cell_name/timing]
```

获取pin名称列表

```tcl
# pin格式: $lib_name/$cell_name/$pin_name
set pin_names [get_lib_pins -all -of_objects $frame_name]
```

判断是否为空

```tcl
set lc [get_lib_cells */*/frame]
if {[sizeof_collection $lc]} {
    puts "not empty"
}
```

添加/获取 antenna 属性

```tcl
foreach cell [get_lib_cells] {
    foreach pin [get_lib_pins -all -of_objects $cell] {
        # 插入
        set_attribute -quiet $pin gate_area "oxide1 [get_object_name [get_layers -filter mask_name==metal1]] 0.00504"
        set_attribute -quiet $pin diff_area "[get_object_name [get_layers -filter mask_name==metal1]] 0.00288"
        # 获取
        set gate_area [get_attribute $pin gate_area]
        set diff_area [get_attribute $pin diff_area]
    }
}
```

### 创建 ndm

```sh
icc2_lm_shell -f test.tcl
```

```tcl
# test.tcl
set WORK_SPACE      "test"              # workspace名称，一般使用library名称
set GDS_FILE        "test.gds"          # gds路径
set TECH_FILE       "test.tf"           # technology文件路径

set search_path     ". views scripts"   # 设置文件查找路径
set LAYER_MAP_FILE  layer.map           # 含义参考read_gds命令帮助-layer_map选项
set BLOCK_MAP_FILE  block.map           # 含义参考read_gds命令帮助-block_map选项

create_workspace $WORK_SPACE -scale_factor 4000 -flow frame -technology $TECH_FILE
# 读取gds
read_gds $GDS_FILE -layer_map $LAYER_MAP_FILE -block_map $BLOCK_MAP_FILE -trace_option auto
# 读取db
read_db -process_label tt0p55v25c ./test1.db
read_db -process_label tt0p55v25c ./test2.db
# 读取lef
read_let ./test.lef

set ndm ${WORK_SPACE}_frame_only.ndm
# 生成ndm
check_workspace
commit_workspace -force -output $ndm
# 进入编辑ndm模式
create_workspace -scale_factor 4000 -flow edit $ndm

# 创建block
create_block test

# 插入antenna信息
set lc [get_lib_cells */CELL_NAME/frame]    # 获取cell对象
if {[sizeof_collection $lc]} {              # 判断cell对象是否有效
    set lp [get_lib_pins -all -of_objects $lc -filter name==A]                                  # 获取pin对象
    set_attribute -quiet $lp gate_area "oxide1 [get_object_name [get_layers -filter mask_name==metal1]] 0.00554"   # 为pin对象添加属性
    get_attribute $lp gate_area             # 获取pin对象属性
}

# 保存ndm
check_workspace
commit_workspace -force -output $ndm
```

## 命令

```tcl
gui_start       # 打开界面
open_lib        # 打开 ndm
```
