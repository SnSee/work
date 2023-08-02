
# cadence

导出gds

```sh
# 需要在导出位置有cds.lib目录，记录库目录信息
strmout -library <library-name> -topCell <cell-name> -view layout -strmFile <export.gds>
```
