
# cadence

|软件 |描述
|- |-
|virtuoso   | layout，schematic
|strmin     | import gds
|strmout    | export gds
|si         | export cdl
|abstract   | export lef

## cds.lib

在当前 cds.lib 中导入其他的 cds.lib

```txt
INCLUDE /tmp/cds.lib
```

导入 foundry 提供的工艺库

```txt
# 创建名为 ln04lpp 的工艺库
DEFINE ln04lpp      /tmp/CDS/oa/ln04lpp
DEFINE ln04lpp_esd  /tmp/CDS/oa/ln04lpp_esd
DEFINE ln04lpp_tech /tmp/CDS/oa/ln04lpp_tech_14M_3Mx_2Fx_7Dx_2Iz_LB
```

## 导出gds

```sh
# 需要在导出位置有cds.lib目录，记录库目录信息
# 或者通过 -cdslib </tmp/cds.lib> 指定
strmout -library <library-name> -topCell <cell-name> -view layout -strmFile <export.gds> -enableColoring
```

## 导出cdl

[export_cdl](./export_cdl/README.md)

## 导出lef

[export_lef](./export_lef/README.md)

## 导入gds

```sh
strmin -library <library-name> -strmFile <import-gds> -attachTechFileOfLib <tech-name> -noWarn '154 156' -logFile 'strmIn.log'
```
