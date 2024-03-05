
# abstract

教程: abstract 打开软件，点击 Help -> Tutorial

默认 options 文件: .abstract/<library_name>/.abstract.options，会自动加载和保存

## gui用法

### 启动界面

```sh
# 在有 cds.lib 的目录执行，或者通过 -cdslib 指定
bsub -Ip abstract
```

### 导入库

File -> Library -> Open -> 选择库名 -> 确定

在 Bin 窗口会列出导入的 cell

### 设置 pin

选中一个 Cell(点击列名可以全选) -> Flow -> Pins -> 根据需要修改设置 -> 点击Run

Pins 列会显示状态

### Extract

选中一个 Cell(点击列名可以全选) -> Flow -> Extract

* Signal tab页 -> 取消勾选 Extract signal nets
* Antenna tab页 -> 勾选需要提取antenna的pin
* General tab页 -> 设置layer间连接关系(前两个layer通过第三个layer连接)

### Abstract

选中一个 Cell(点击列名可以全选) -> Flow -> Abstract

### 导出 LEF

File -> Export -> LEF -> 设置 LEF 版本等选项 -> 确定

会在当前目录保存 options 文件: .abstract/<library_name>/.abstract.options

## 脚本运行

1. 通过 gui 方式运行一遍，获取 .abstract/<library_name>/.abstract.options
2. 用 .abstract.options 取代 export_lef/scripts/abstract.options
3. [export_lef](./export_lef/README.md)

## 可能需要修改的 options

1. 在 Cadence Help 窗口搜索 **absSetBinOption**，查看函数用法
2. 在 ICADVM / SKILL / VirtuosoLayoutSuiteSKILLReference / AbstractGeneratorFunctions 页面搜索 <option_name> 查看含义

|var | path
|- |-
|USER_GUIDE     | ICADVM / VirtuosoLayoutSuite / VirtuosoAbstractGeneratorUserGuide
|EXTRACT_STEP   | $USER_GUIDE / ExtractStep

option 值类型

|option value type | description | doc | example
|- |- |- |-
|geom_spec         | geometry区域，由 layer 运算得到 | $EXTRACT_STEP / Specifying Layers and Geometries for Extration | (M2 (M2 andnot M3)): 将M2中非M3的部分提取到M2
|layers            | tech layermap中定义的层次编号  |   | M1 M2
|true\|false       | 开关 | | true
|clock_pin_names   | pin 名称 | | CK CLK

### 通用设置

|option | 设置方式
|- |-
|LEFLibraryName | 修改为实际的库名
|ViewLayout     | 修改为 layout_lef

### Bin 设置(Core/IO/Corner/Block都有各自的设置)

|option | 设置方式
|- |-
|AbstractAdjustAllowPin         | 提取pin时调整指定层次的提取逻辑，如 M1 都算 pin 修改为 M1 上未与 X1 交叉部分算pin: (M1 (M1 drawing andnot X1 drawing))
|AbstractAdjustClassCoreNets    | 根据实际 power pin 名称添加到默认的正则里即可
|AbstractAdjustPowerRailOp      | 需要PROPERTY的pin？如: VDD abutment 0.046 0.177 VSS abutment 0.046 -0.023
|AbstractAdjustStairStepWidth   | ?? 根据实际情况设置宽度
|AbstractBlockageCoverLayers    | 设置blockage层，指定的layer不算pin的都算OBS
|AbstractBlockageCutAroundPin   | 设置与临近的pin切断连接关系的blockage层
|AbstractBlockageDetailedLayers | 设置提取OBS的layer，支持写法: (CA (CA drawing andnot CX drawing))
|AbstractBlockageFracture       | true 表示blockage提取为 RECT，false为POLYGON
|AbstractBlockageTable          | 设置哪些层抽取 blockage
|AbstractDensityLayers          | 金属层密度layer??
|AbstractOverlapLayers          | ??
|AbstractOverlapLayerSize       | ??
|AbstractPinFracture            | ??
|AbstractSiteName               | 指定 Macro 中引用的 SITE 名称
|AbstractSiteNameDefine         | 创建 SITE 定义
|ExtractAntennaDrain            | 指定漏极区域，计算 DIFFAREA 时会移除该区域面积，如：(RX (RX andnot FC))
|ExtractAntennaGate             | 指定 GATEARAE
|ExtractAntennaLayers           | 哪些 layer 提取 antenna 信息，只有 LEF5.4 需要指定
|ExtractAntennaMetalArea        | 是否计算制造layer时连接到pin的金属面积
|ExtractAntennaMetalSideArea    | 是否计算连接到引脚的金属的侧面积(周长x厚度)
|ExtractAntennaNoAdjust         | ??
|ExtractAntennaSizeInout        | 不需要 inout pin 的 antenna 设为 false
|ExtractConnectivity            | 设置 layer 连接关系，如: (M1 M2 V1)(M2 M3 V2)
|ExtractDiffAntennaLayers       | 是否在提取antenna时为不同层分别提取
|ExtractLayersPwr               | ??
|ExtractLayersSig               | ??
|ExtractPinLayersPwr            | ??
|ExtractPinLayersSig            | 设置 pin 所在的 layers
|ExtractSig                     | 是否提取 signal nets 连接关系
|PinsBoundaryLayers             | ???
|PinsClockNames                 | clock pin 名称正则表达式，用空格分隔
|PinsGroundNames                | ground pin 名称正则表达式，用空格分隔
|PinsOutputNames                | 输出 pin 名称正则表达式，用空格分隔
|PinsPowerNames                 | power pin 名称正则表达式，用空格分隔
|PinsPwrRoutingLayers           | ???
|PinsTextPinMap                 | 设置 pin label 和 polygon 对应关系，如: ((M1 label)(M1 drawing))((M2 label)(M2 drawing))
