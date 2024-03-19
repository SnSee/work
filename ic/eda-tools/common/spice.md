
# spice

如果安装了 hspice， 可以在 docs_help/ni 下查看相关文档

## 语法

hspice 文档: <hspice_help>/hspice_elements.pdf

### Capacitor 电容

#### Linear Capacitor

```sh
# 基础语法
Cxxx n1 n2 [mname] [C=]capacitance

Cxxx: 名称，必须以 C 开头
n1  : 正电荷节点(positive terminal node)名称
n2  : 负电荷节点(negative terminal node)名称
[C=]capacitance: 电容值，单位: 法(f,farads) 或 参数名(由 .PARAMETER 定义)
```

### MOSFET

```sh
# 基础语法
Mxxx nd ng ns [nb] mname [[L=]length] [[W=]width]

Mxxx : 名称
nd   : 漏极(drain terminal node)
nd   : 栅极(gate terminal node)
ns   : 源极(source terminal node)
nb   : bulk terminal node
mname: 引用的 MOSFET 名称
L    : MOSFET channel length
W    : MOSFET channel width
```
