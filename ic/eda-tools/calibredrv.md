
# calibredrv

打开calibredrv界面通过 **help -> Open User Manual** 查看用户手册

[参考脚本](../scripts/calibredrv.tcl)

## 启动

```sh
# 进入交互页面，默认打开 gui
calibredrv -shell   # 交互页面使用tcl语法

# 其他命令行选项
-s : 启动时加载tcl脚本
-m : 启动时加载layout(.gds或.oasis)，多个文件需指定多次
-l : 指定layermap文件，需要和 -m 一起使用

calibredrv test.tcl         # 执行脚本中的命令后退出
```

> **注意**

* 通过calibredrv提供的tcl函数获取的数据单位为 **database unit (dbu)**，需要乘以系数才是实际的数据, 系数可以通过 **$L units user** **(uunit)** 获取

## 命令

### Layout 命令

manual目录（第5页）Layout Object 项下有layout相关所有命令

```tcl
# -dt_expand: 可选项，展开datatype到layer, 
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
$L iterator text <cell_name> <layer_number> range 0 end
# 返回值为多个 {text:string x:int y:int}

# 遍历/获取所有polygon
set unit [$L units user]
set polygons [$L iterator poly <cell_name> <layer_number> range 0 end]
# polygons格式如下
# { {x1 y1 x2 y2 ... xn yn} ...}
foreach poly $polygons {
    foreach xoy $p {
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
