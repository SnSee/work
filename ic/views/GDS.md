# GDS

[c++解析框架](https://github.com/EDDRSoftware/gdsFileParser)

## 标志位

[数据来源](https://blog.csdn.net/GaleZhang/article/details/108849673)

|第3、4字节标志位|类型|数据参数类型
| :-- | :-- | :-- |
|00 02  |HEADER(文件头)           |int16
|01 02  |BGNLIB(库文件头)         |12个int16
|02 06  |LIBNAME(库文件名)        |ASCII字符串
|1F 06  |REFLIBS(参考文件)        |90个char
|20 06  |FONTS(字体)              |176个char
|23 06  |ATTRTABLE(属性)          |44个char
|22 02  |GENETATIONS(备份文件数)  |int16
|36 02  |FORMAT(格式)             |int16
|37 06  |MASK(掩膜)               |ASCII字符串
|38 00  |ENDMASK(掩膜结束)        |无
|03 05  |UNITS(单位)              |2个float64
|05 02  |BGNSTR(模块结构头)       |12个int16
|06 06  |STRNAME(模块结构名)      |最多32个char
|08 00  |BOUNDARY(填充多边形)     |无
|09 00  |PATH(线条)               |无
|0A 00  |SREF(模块插入属性)       |无
|0B 00  |AREF(阵列)               |无
|0C 00  |TEXT(文字)               |无
|15 00  |NODE(拓扑点)             |无
|2D 00  |BOX                      |无
|26 01  |ELFLAGS                  |int16
|2F 03  |PLEX                     |int32
|0D 02  |LAYER(层)                |int16
|0E 02  |DATATYPE(数据类型)       |int16
|10 03  |XY(坐标)                 |最多200个int32
|21 02  |PATHTYPE(线端类型)       |int16
|0F 03  |WIDTH(宽度)              |int32
|12 06  |SNAME(插入模块结构名)     |最多32个char
|1A 01  |STRANS(坐标变换)         |int16
|1B 05  |MAG(缩放)                |int64
|1C 05  |ANGLE(角度)              |int64
|13 02  |CLOROW(行列数)           |2个int16
|16 02  |TEXTTYPE(文字类型)       |int16
|17 01  |PERSENTATION             |int16
|19 06  |ASCII STRING(字符串)     |最多512个char
|2A 02  |NODETYPE(拓扑点类型)     |int16
|2E 02  |BOXTYPE                  |int16
|11 00  |ENDNET(图素参数结束)     |无
|07 00  |ENDSTR(模块结构结束)     |无
|04 00  |ENDLIB(库文件结束)       |无

## 图形

* origin: 原点(x, y)
* R90   : 逆时针旋转 90 度
* R180  : 逆时针旋转 180 度
* R270  : 逆时针旋转 270 度
* MX    : 沿 origin-y 刻度的 X 轴方向镜像
* MY    : 沿 origin-x 刻度的 Y 轴方向镜像

## pin

```text
# 以gdspy为例
class Label:
    text: str                       # label名称（对于pin则是pin名称）
    texttype: int                   # label类型，取值范围[0-255]
    position: list[float, float]    # label坐标
class Polygon:
    layer: list[int]                # polygon所在layer
    datatypes: list[int]            # polygon类型，取值范围[0-255]
    polygons: list[Point]           # 组成polygon的点

pin的Label:
    text: pin名称
    texttype: 特定值，如: 20
pin的Polygon:
    layer: 特定值，如: [15]         # 一般用 15 表示M1
    datatypes: 特定值，如: [236]    # pin的datatypes可能有多种，如 236，239等
    polygons: 一般是有四个点的矩形
```
