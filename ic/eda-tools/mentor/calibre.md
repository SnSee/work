
# calibre

## summary

设置calibre版本

```csh
# 设置环境变量，不能通过修改可执行程序指定版本
# 设置的路径下一级就有bin目录
setenv CALIBRE_HOME /eda-tools/mentor/calibre202104/aoj_cal_2021.4_25
```

## DRC/LVS/ERC

```bash
# <runset_file>一般由芯片制造商提供

# DRC
calibre -drc -hier <runset_file>

# LVS(ERC)
calibre -lvs -hier -spice lay.net -turbo 4 <runset_file>
```

查看drc检查结果

```text
Calibre 进行 DRC 检查后，可以通过查看生成的 DRC 摘要报告文件来了解检查的结果。DRC 摘要报告文件通常是一个具有 ".sum" 扩展名的 ASCII 文本文件。
若存在 DRC 失败情况，DRC 摘要报告文件中对应的规则数目将会被标记为非零值，若无 DRC 失败情况，则所有规则的出现次数都为零。
然后可在 ".rep" 和将标准输出重定到的日志文件中查看更多细节。
```

使用gui查看检查结果

```text
1. calibre -gui 打开界面
2. 选择 RVE
3. Database选择 .rep 文件，点击 Open 按钮
```

## LVL

[知乎](https://zhuanlan.zhihu.com/p/148105306)

```bash
# 指定 -resultformat ASCII 时导出 ascii 格式文件，不指定时导出 gds
dbdiff -refsystem GDS -system GDS -refdesign top_ref.gds top_cell -design top.gds chip_top -write_xor_rules xor.rul diff -resultformat ASCII
calibre -drc -hier -turbo -hyper -fx xor.rul | tee xor.log &
```

参数：
-turbo <number_of_processors>
-turbo_all

## runset

DRC 检查只会对在runset中设置为PRIMARY的cell进行检查，但支持通配符设置多个cell

> 主要原因是，Calibre需要知道应该检查哪些设计、库和规则文件，并使用runset文件来指导它应该检查哪些单元。其中，在runset中设置为PRIMARY的cell会被视为需要进行DRC检查的主要单元，而其他单元则可能作为引用单元或black box单元被忽略掉。
>
> 当然，除了PRIMARY cell外，还可以选择将其他类型的单元包含在内，如LEF或GDS库、SPICE模型等；这些单元可以在runset中通过添加INCLUDE或EXCLUDE语句进行指定。

LVS 检查通常只需要针对设置为 PRIMARY 的 cell 进行检查。

> 这是因为 PRIMARY cell 通常被视为整个设计的顶层单元，并且包含了其他所有库单元和设计结构。
>
> 在 LVS 检查中，Calibre 将会通过比较 Layout 和 Source 两者内容来执行验证，以确保它们是匹配的，包括网络拓扑、连线等方面。与 DRC 类似，LVS 检查也将使用 runset 文件来指定需要进行比较的单元和规则。
>
> 但是需要注意的是，在某些情况下可能需要对其他类型的单元进行 LVS 比较和验证，例如在使用 hierachical flow 进行大型 SoC 设计时，可能需要对子芯片或 block instances 进行 LVS 验证，而非仅限于 PRIMARY cell。在这种情况下，runset 文件需要相应地指定要包含在比较过程中的所有单元。
