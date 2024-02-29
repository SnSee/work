
# View Summary

## 生成与解析

|view       |description    |generation |parse
|-          |-              |-          |-
|gds        | 版图信息              | layout 工程师画             | calibredrv / gdspy
|verilog    | gate-level/rtl 网表 | k库或design                   | slang-verilog
|liberty    | 时序及功耗信息       | k库                          | libertyParser
|db         | 时序及功耗信息       | lc_shell 基于liberty 生成    | NA
|cdl        | 前仿网表              | si导出schematic(ICADVM)     | regex
|spice      | 后仿网表              | StarXtract抽取              | regex
|lef        | 物理信息              | abstract基于gds和工艺库抽取    | lefdef
|ndm        | ?                     | icc2整合gds/lef/liberty等 | icc2_lm_shell
|readhawk   | 功耗分析               | ?                          | NA
|fastscan   |tessent库文件   | tessent基于verilog生成 | NA
|masis      |memory信息     | ?                 | NA
|bitmap     |memory位图信息  | msview基于masis | NA
