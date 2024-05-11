
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

## 示例

```sh
.TITLE 第一行被视作标题

.lib /tmp/test.lib TT       # 引用库，corner 为 TT
.include /tmp/test.inc      # 包含文件

# LIST: 打印输入数据清单
# NODE: 打印节点列表
# POST: 存储数据格式
.options LIST NODE POST

# 定义变量
.param name1=value1 name2=value2

# 定义元器件
R1 1 2 10k                  # 定义节点1,2间 10kΩ 电阻
C1 1 2 10k                  # 定义节点1,2间 1pf 电容
L1 1 2 1mh                  # 定义节点1,2间 1mh 电感

# 定义 mos 管
## ND 漏极
## NG 栅极
## NS 源级
## NB 衬底
## MNAME mos管名称
## L 沟道长度
## W 沟道宽度
M1 ND NG NS NB MNAME L=1 W=1

# 激励
## 独立电压源
### 直流源
VDD 1 0 DC 5v               # 节点1,0间加 5v 电压
V1 1 0 10 AC 1              # 节点 1,0 间，加直流电压 10v 和幅值为 1v 的交流电压

# 定义子电路
.SUBCKT SUB_NAME PIN1 ...
...
.ENDS

# 创建 instance
X1 PIN1 ... SUB_NAME

# 直流分析
.op

# 交流分析
.ac DEC 10 1K 1MEG          # 从 1-10kHz，每个量级取 10 个点分析

# 瞬态分析
.tran 1n 1u 0               # 以 1ns 为步长，分析 0 - 1us

.temp 25 50 75              # 指定 3 个仿真温度

# 打印交流分析类型的节点 1,2 的 电压，以及 R2,C1 的电流
V1 1 0 10 AC 1
R1 1 2 1K
R2 2 0 1K
C1 2 0 .001U
.print AC V(1) V(2) I(R2) I(C1) 
```
