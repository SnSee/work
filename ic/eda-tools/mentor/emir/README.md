
# emir README

## 用法

```txt
1. 复制工厂提供的 CalibreXRC 的 sourceme_xact 到 emir_py/etc/sourceme_xact.ln04lpp:
    修改 TECHDIR, TECHDIR_xACT, BEOL_STACK 等
    添加 setenv EXTRACT_NF_PEX TRUE
    修改 setenv PORT_DEPTH PRIMARY
    修改 setenv TEXT_DEPTH PRIMARY
    修改 setenv VIRTUAL_CONNECT "VDD VSS"
2. 把 LsfManager 和 LogHandler 添加到 PYTHONPATH
3. 修改 cfg 中的路径为实际的文件路径
4. chmod +x run emir_py/emir.py
5. ./run
6. 查看 report 文件: *.rpt_em, *.rpt_ir
```

## 原理

```txt
1. 对 gds 和 cdl 抽 LPE
2. 使用 calibre 提取 dspf (calibre -gui -xact)
3. 基于 dspf 使用 spectre 等仿真工具跑仿真
```
