
# calibredrv

文档位置：manuals/ic/mentor/calibre，查看 calbr_drv_ref.pdf(2012版) 或者 calbr_cwbTcl.pdf(2006版)
或者打开calibredrv界面通过 help -> Open User Manual 查看
以下示例以 **2012** 版本为例。

[参考脚本](../scripts/calibredrv.tcl)

启动

```sh
# 进入交互页面，默认打开 gui
calibredrv -shell   # 交互页面使用tcl语法

# 其他命令行选项
-s : 启动时加载tcl脚本
-m : 启动时加载layout(.gds或.oasis)，多个文件需指定多次
-l : 指定layermap文件，需要和 -m 一起使用
```

> **注意**

* 通过calibredrv提供的tcl函数获取的数据单位为database unit，需要乘以系数才是实际的数据(系数可以通过 **$L units user** 获取)

layout的一些命令

manual目录（第5页）Layout Object 项下有layout相关所有命令

```tcl
# -dt_expand: 可选项，展开datatype到layer, 
# 如 layer 15, datatype 235和236 分别表示为 15.235, 15.236
set L [layout create test.gds -dt_expand]       # 加载gds，通过对象L访问
$L gdsout new.gds                               # 导出gds

$L layers                   # 查看所有层次
$L exists layer 15          # 查看是否有某一层次，1表示有，0表示没有
$L layernames 15 M1         # 设置layer名称
$L layernames 15            # 查看layer名称
$L layernames               # 查看所有layer名称，没有名称的显示为layer值
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

# 给定坐标点获取polygon
# 返回值各项含义查看 （2012版 P.184 polygon项）
# 返回值为n个 {layer x1 y1 ... xn yn} idx v|e distance {x y}
$L query polygon <cell_name> 0 100 <x> <y> -inside
```
