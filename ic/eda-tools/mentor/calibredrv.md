
# calibredrv

打开calibredrv界面通过 **help -> Open User Manual** 查看用户手册，或者查看同级或子目录中是否有 doc* 文件，找到 index.html 打开后在 Physical Verification 中查找 DESIGNrev 后打开

[参考脚本](../scripts/calibredrv.tcl)

## 启动

```sh
# 进入交互页面，默认打开 gui
calibredrv -shell           # 交互页面使用tcl语法
calibredrv test.tcl         # 执行脚本中的命令后退出

# 其他命令行选项
-s : 启动时加载tcl脚本
-m : 启动时加载layout(.gds或.oasis)，多个文件需指定多次
-l : 指定layermap文件，需要和 -m 一起使用
```

> **注意**

* 通过calibredrv提供的tcl函数获取的数据单位为 **database unit (dbu)**，需要乘以系数 **(uunit)** 才是实际的数据(单位: 微米), 系数可以通过 **$L units user** 获取，**不要直接修改dbu/uunit，而是通过修改 units microns 间接修改**，否则可能会导致单位错乱

## 命令

### 长度单位

* dbu: database unit，calibredrv中最小长度，默认单位为 1e-9米，尺寸信息一般都是这个单位，如 1 微米表示为 1e-6/1e-9 = 1000dbu，小于这个尺寸的数值会被四舍五入，如 1e-9 和 1.4e-9 都是 1dbu.

```tcl
set L [layout create]

# 1 微米包含多少个 dbu (即精度)
$L units microns
# 如：设置 1 微米包含 x 个 dbu
# 则：1dbu = 1e-6/x 米，1uunit = 1dbu/1e-6 = 1/x
$L units microns 100
puts [$L units database]        # 1e-8
puts [$L units user]            # 1e-2
```

### Layout 命令

manual目录（第5页）Layout Object 项下有layout相关所有命令

|layout create 选项 | 含义
|- | -
|-dt_expand                 | layer.datatype 格式表示 layer
|-preserveProperties        | 保留 property 信息
|-preserveTextAttributes    | 保留 text(label) 属性
|-ignoreInsts               | 不加载 instance
|-ignorePaths               | 不加载 path
|-ignorePolys               | 不加载 polygon
|-ignoreTexts               | 不加载 text(label)

```tcl
# 如 layer 15, datatype 235和236 分别表示为 15.235, 15.236
set L [layout create test.gds -dt_expand]       # 加载gds，通过对象L访问
$L gdsout new.gds                               # 导出gds
$L oasisout new.oasis                           # 导出oasis

$L cells                    # 获取所有cell名称
$L layers                   # 查看所有层次
$L exists layer 15          # 查看是否有某一层次，1表示有，0表示没有
$L layernames 15 M1         # 设置layer名称
$L layernames 15            # 查看layer名称
$L layernames               # 查看所有layer名称，没有名称的显示为layer值

##################################################
# layer 间操作
##################################################
# 从 layer_main 中除去 layer_cut 后剩余的部分保存到 layer_out
$L NOT $layer_main $layer_cut $layer_out

# 通过 layer_con 连接 layer1 和 layer2，保存到 layer_out
# 注意： layer_out 原有多边形会被清空
$L connect $layer1 $layer2 by $layer_con
foreach polygons [$L iterator poly $cellName $layer1 range 0 end] {
    set x0 [lindex $polygons 0]
    set y0 [lindex $polygons 1]
    set exed [$L extractNet $cellName -geom $layer1 $x0 $y0 -hier 0 -export $layer_out]
    puts "$x0, $y0 -> $layer_out: $exed"
}
```

#### iterator

```tcl
# 遍历 poly, wire, text
$L iterator {poly | wire | text} <cell_name> <layer_number> range 0 end
# poly返回值:  [properties] {x1 y1 ... xn yn}
# properties: layout create 时指定 -preserveProperties 才有，列表类型

# 遍历引用关系(获取cell中instance信息)
# 返回1个或多个: list[x y mirror angle magnification [properties]]
# x, y: ref_cell在cell中位置，单位: dbu
# properties: layout create 时指定 -preserveProperties 才有，列表类型
$L iterator {ref | sref | aref} <cell_name> range 0 end
```

```tcl
# 遍历text
$L iterator text <cell_name> <layer_number> range 0 end -preserveTextAttributes
# 返回值为多个 {text:string x:int y:int}

# 遍历/获取所有polygon
set unit [$L units user]
set polygons [$L iterator poly <cell_name> <layer_number> range 0 end]
# polygons格式如下
# { {x1 y1 x2 y2 ... xn yn} ...}
foreach poly $polygons {
    foreach xoy $poly {
        # 多边形顶点的x或y值
        puts [expr $xoy * $unit]
    }
}
```

#### query

```tcl
# 给定坐标点获取polygon
# 返回值各项含义查看 （2012版 P.184 polygon项）
# 返回值为n个 {layer x1 y1 ... xn yn} idx v|e distance {x y}
$L query polygon <cell_name> 0 100 <x> <y> -inside
```

#### create

#### modify

#### delete

#### tips

##### 获取 pin 对应的多层 polygons

1. 通过 **NOT** 命令剪切 metal layers，导出为新的 metal layers
2. 通过 **connect** 命令连接新的 metal layers
3. 通过 **iterator text** 命令获取 pin 名称及位置(pin_label_pos)
4. 通过 **extractNet** 命令根据 pin_label_pos 追溯 polygons，导出到 layer_out
5. 通过 **iterator poly** 命令获取 layer_out 对应 polygons
