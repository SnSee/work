
# cdl

## 语法

```cdl
* 注释
.SUBCKT top_cell pin1 pin2 pin3 key1=val1 key2=val2
* I 表示 input, O 表示 output，B 表示 inout
*.PININFO pin1:I pin2:O pin3:B

.ENDS

.SUBCKT top_cell pin1 pin2 pin3 key1=val1 key2=val2
*.PININFO pin1:I pin2:O pin3:B

* 名称为M0的mos管
MM0 pin1 pin2 pin3 mos_name

* 名称为C0的instance
XC0 pin1 pin2 pin3 / sub_cell key1=val1 key2=val2

* 名称为R0的电阻，连接在N2和N3之间，阻值为10kΩ
RR0 N2 N3 10k

.ENDS
```
