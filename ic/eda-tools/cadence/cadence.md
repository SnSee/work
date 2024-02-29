
# cadence

|软件 |描述
|- |-
|virtuoso   | layout，schematic
|strmin     | import gds
|strmout    | export gds
|si         | export cdl
|abstract   | export lef

## 导出gds

```sh
# 需要在导出位置有cds.lib目录，记录库目录信息
strmout -library <library-name> -topCell <cell-name> -view layout -strmFile <export.gds>
```

## 导出cdl

[export_cdl](./export_cdl/README.md)
