
# SVRF / TVF

doc: Physical Verification -> **Standard Verification Rule Format (SVRF) Manual**

**TVF**  命令文档: 在 SVRF 中搜索 TVF Command Reference

[TVF vs SVRF](https://blog.csdn.net/graymount/article/details/106640839)

* TVF: Tcl Verification Format
* SVRF: Standard Verification Rule Format
* 如果文件第一行是 **#! tvf**，那么，这就是一个Compile-Time TVF，里面就是 tcl 语法
* TVF 是 calibre 的 TCL 命令，可以使用 TCL 语法
* SVRF 是 calibre 自身的语法，通过 [tvf::VERBATIM](#verbatim) 可以在 TVF 中使用 SVRF
* TVF 可以使用一部分 SVRF 的命令
* TVF 和 SVRF 区别搜索 "Difference Between TVF and SVRF"
* TVF 中使用 source，SVRF 中使用 INCLUDE

```tcl
#! tvf
# 导入内置 tvf 命令
namespace import tvf::*
```

## 命令

### SVRF 调用 TVF

tvf::svrf_var 获取 SVRF 中定义变量

```svrf
VARIABLE varInSvrf 0.1

TVF FUNCTION tvfFunc [/*
    tvf::GET_LAYER_ARGS L1 L2
    set dist [tvf::svrf_var varInSvrf]
    tvf::OUTLAYER "EXTERNAL $L1 $L2 <= $dist REGION OPPOSITE"
*/]

// 将 A，B 传给 L1，L2
layer1 = TVF tvfFunc A B
```

### TVF 调用 SVRF

使用 SVRF 编译器编译其中内容(已经脱离 tcl 解释器了)

```tcl
tvf::VERBATIM {
    ...
}
```

### SVRF 调用 SVRF

调用其他 svrf 文件

```svrf
INCLUDE "test.drc.svrf"
```

### VARIABLE

```svrf
VARIABLE name value                     // 创建变量

VARIABLE width ENVIRONMENT              // 获取 shell 环境变量
VARIABLE half_width width * 0.5         // 使用数学表达式与已有变量
VARIABLE width_exp  "width * 0.5"       // 强制为字符串
```

### PRECISION

```svrf
PRECISION 1000                          // 设置精度，1000 表示精度为 1um / 1000 = 1nm
```

### LAYOUT

```svrf
LAYOUT SYSTEM   GDSII
LAYOUT PATH     test.gds                // 指定 gds 路径
LAYOUT PRIMARY  top_cell                // 指定对哪个 cell 做 DRC/LVS 等
```

### DRC

```svrf
DRC RESULTS DATABASE test.rdb           // 检查结果文件
DRC SUMMARY REPORT   test.rpt           // report
```

### AND

```svrf
AND layer1                  # layer1 自身有重叠部分(polygons)
AND layer1 layer2           # layer1 和 layer2 重叠部分(polygons)
```

### LAYER

```svrf
LAYER POLY  1
LAYER NPOLY 31
LAYER PPOLY 32
```

```tcl
# 创建 layer 变量
tvf::LAYER POLY     1
tvf::LAYER NPOLY    31
tvf::LAYER PPOLY    32

# layer 运算与赋值
tvf::SETLAYER ALL_POLY = (POLY OR NPOLY) OR PPOLY

# 使用变量
set GR1 3.4
tvf::SETLAYER LARGE_POLY = "SIZE ALL_POLY BY $GR1"
```

### EXTERNAL

EXTERNAL layer1 constraint [...]
EXTERNAL layer1 layer2 constraint [...]

测量 layer 自身或两个 layer 间外边缘距离，返回符合条件的边所构成的多边形？

```svrf
// 获取 lay1 lay2 距离小于 0.04 且夹角小于 90 度的边所构成多边形
x = EXT lay1 lay2 < 0.04 ABUT < 90 OPPOSITE REGION
```

### 定义检查规则

RuleName 即是 report 中 RULECHECK 字段名称
不满足条件的 polygon / line 等会写入到 results database

```svrf
RuleName {
    EXTERNAL 15 17 < 0.25
    ...
}
```
