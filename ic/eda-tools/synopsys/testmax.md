
# testmax

synopsys公司

## msview

masis 查看器，直接执行程序打开界面即可，界面很简单

## mivm

### masis 转 bitmap

文档：masis_compiler_generic.pdf，如果加密了需要破解

#### 配置及命令

cnt.txt (Bitmap Control Files，控制转 bitmap 一些选项)

```sh
MASIS_TO_BITMAP
# masis 文件所在目录
masis_files = <masis_dir>
# 要生成的bitmap文件目录
bitmap_files = <bitmap_dir>

# 默认 word，不同值生成的bitmap格式不一样
bitmap_type = <word | cell>

# x,y坐标轴向右/上增长，偏移量都为正值
# left-most x 向右偏移量
bit_line_offset_X = <real>
# bottom y 向上偏移量
bit_line_offset_Y = <real>
# right-most x 向左偏移量
bit_line_offset_X_ = <real>
# bitmap_type = word 时: bottom y 向上偏移量
# bitmap_type = cell 时: top y 向下移量
bit_line_offset_Y_ = <real>
```

转换命令

```sh
# 命令中的tcl是程序内置的，可在 $TestMax_dir/data/masis/mivm_scripts 下查看
mivm -ps masisToBitmap.tcl -c cnt.txt
```

#### bitmap 文件格式介绍

bitmap文件格式，以 word = m，bit = k，mux = 2 的 memory 为例
bitmap_type = word
设：n = m - 1

* 第一列为十六进制数字，表示 address 编号
* bit[i] 中 i 表示 bit 索引，不带下划线表示left-bottom坐标点(offset之后)，带下划线表示right-bottom(offset之后)
* 当 bit cell 镜像时(BitLineMirroring为TB?)，left-bottom 和 right-bottom 坐标位置互换，即不带下划线对应right-bottom
* 当 mux > 1 时，每个 bit 分为 mux 个单元格，其 address 编号从左到右和 masis 中 PhysicalColumnSequence 字段一一对应，如 mux = 2, PhysicalColumnSequence = {{01 00} ...}, 每个 bit 包含 2 个单元格，单元格从左到右 address 编号依次为 01, 00

|address | bit(0)-lb | bit(0)-rb | ... | bit(k)-lb | bit(k)-rb |
| --     | --        | --        | --  | --        | --        |
| 00     | x00,y00   | x00_,y00_ | ... | x0k,y0k   | x0k_,y0k_ |
| 01     | x10,y10   | x10_,y10_ | ... | x1k,y1k   | x1k_,y1k_ |
| ...
| hex(n) | xn0,yn0   | xn0_,yn0_ | ... | xnk,ynk   | xnk_,ynk_ |
