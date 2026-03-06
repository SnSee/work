
# verdi

命令行参数

|arg | desc
|- |-
|f/F    | 指定含有多个 verilog 文件路径的文件
|ssf    | 指定 fsdb/vcd 波形文件
|mdt    | 指定 mdt 文件
|sv     | 支持 system-verilog(IEEE 1800-2005)

## 基础用法

1.点击工具栏 New WaveForm
2.将 Instance 界面被测试 instance 拖动到 Waveform 界面
3.点击 Run Simulation 按钮开始测试
4.在 Waveform 界面查看波形
5.更多介绍查看 \<\<VCS QuickStart\>\> Setting up the simulation for debug 章节

## 查看，保存，加载信号

```yml
show signal : 
    - rtl 在要查看的信号右键 -> Add to Waveform
    - rtl 左键按住拖动
shift + s   : 保存当前 waveform 所有信号到 rc 文件
r           : 加载 *.rc 信号文件
h           : 显示信号全路径

跳转到信号改变位置    : 工具栏左右方向按钮可以跳转到 上/下 一次信号改变的位置，快捷键 N/Shift-N
    - 注意: 前边的 By 要选择 Any Change
跳转到指定信号值位置  : 同上，By 要选择 Bus Value
```

## 导出命令

### fsdb2vcd

```sh
# 将波形导出为 vcd 格式
fsdb2vcd test.fsdb -o test.vcd
    -s          : 指定信号路径，如 /top/inst1
    -level      : 指定 -s 时最大子信号层级
    -bt         : 指定起始时间，如 1000ps，默认单位 ns
    -et         : 指定结束时间
```

### fsdbmerge

```sh
# 合并多个波形文件
fsdbmerge input1.fsdb input2.fsdb -o merged.fsdb
```

### fsdbreport

```sh
# 将波形导出为文本文件
fsdbreport test.fsdb -o test.txt
    -s          : 指定信号路径，如 /top/inst1
    -level      : 指定 -s 时最大子信号层级
    -w          : 指定信号位宽，默认情况下高位可能不显示
    -bt         : 指定起始时间，如 1000ps，默认单位 ns
    -et         : 指定结束时间
    -of         : 指定进制，如 h 表示十六进制
    -exp        : 指定表达式，只有表达式为真时才导出，如 "/top/we & /top/ge"
    -csv        : 导出为 csv 格式
    -period     : 每隔指定时间 dump 一次值，时间单位查看 csv 输出中第一列 Time
                : 必须搭配 -exp 一起使用，否则提取不出来？
                : 默认是当信号值变化时 dump，使用 period 时和信号值是否变化无关，推荐参考时钟频率进行设置

# 导出多个信号为 csv 格式
fsdbreport test.fsdb -o signals.csv -of h -csv -s sig1 sig2
```
