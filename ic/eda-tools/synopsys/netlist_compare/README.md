
# LPE README

## 用法

```text
1. 修改 cell_env
2. 修改 scripts/eda.env 中的工具路径
3. chmod +x cmd scripts/run
4. 执行 cmd
```

## 原理

```text
1. 将 cdl/spice 网表通过 wrapper 在 verilog 中引用
2. 使用 vcs 对 verilog 和 wrap 后的 cdl/spice 跑相同的仿真，比较结果
```
