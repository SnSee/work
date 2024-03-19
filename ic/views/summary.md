
# View Summary

## 生成与解析

|view       |description    |generation |parse  | script
|-          |-              |-          |-      |-
|gds        | 版图信息              | layout 工程师画             | calibredrv / gdspy | [export_gds](../eda-tools/cadence/cadence.md#导出gds)
|verilog    | gate-level/rtl 网表 | k库或design                   | slang-verilog | NA
|liberty    | 时序及功耗信息       | k库                          | libertyParser | NA
|db         | 时序及功耗信息       | lc_shell 基于liberty 生成    | NA | [lib2db](../eda-tools/synopsys/lc.md#lc)
|cdl        | 前仿网表              | si导出schematic(ICADVM)     | regex | [export_cdl](../eda-tools/cadence/export_cdl/README.md)
|spice      | 后仿网表              | StarXtract抽取              | regex | [LPE](../eda-tools/synopsys/star_rc/LPE/README.md)
|lef        | 物理信息              | abstract基于gds和工艺库抽取    | lefdef   | [export_lef](../eda-tools/cadence/export_lef/README.md)
|ndm        | ?                     | icc2整合gds/lef/liberty等 | icc2_lm_shell     | [icc2](../eda-tools/synopsys/icc2.md)
|fastscan   |tessent库文件   | tessent基于verilog生成 | NA | [atpg](../eda-tools/mentor/tessent.md#verilog2celllibrary)
|masis      |memory信息     | ?                 | NA | NA
|bitmap     |memory位图信息  | msview基于masis | NA | [mivm](../eda-tools/synopsys/testmax.md#mivm)
|apl        | 电容/电流/电压等信息       | red-hawk apldi/aplsw               | NA  | [redhawk](../eda-tools/apache/reahawk/README.md)

## 比较/diff

|view       |method
|-          |-
|gds        | [LVL](../eda-tools/mentor/calibre.md#lvl)
|verilog    | NA
|liberty    | libLv 脚本, siliconsmart
|db         | NA
|cdl        | NA
|spice      | NA
|lef        | lefDiff 脚本
|ndm        | NA
|fastscan   | NA
|masis      | NA
|bitmap     | NA
|apl        | NA
