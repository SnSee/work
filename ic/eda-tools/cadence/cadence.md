
# cadence

|软件 |描述
|- |-
|virtuoso   | layout，schematic
|strmin     | import gds
|strmout    | export gds
|si         | export cdl
|abstract   | export lef

## cds.lib

```sh
# 在当前 cds.lib 中导入其他的 cds.lib
INCLUDE /tmp/cds.lib
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
