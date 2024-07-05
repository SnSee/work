
# vcs

vcs(Verilog Compiler Simulator) 是电路仿真验证工具，可以进行电路的时序模拟。可以借助 verdi 进行 debug.

## 命令行参数

|arg | desc
|- |-
|-sverilog          | 支持使用 system-verilog 语法
|-fsdb              | 生成波形文件
|-debug_access+all  | debug 模式

## vcs 对 verilog 进行仿真测试

[eetop](https://blog.eetop.cn/blog-283296-29471.html)

一般至少需要两个 .v，一个是被测试的 .v（包含被测试的module），一个是进行测试的 _test.v（包含测试时的top-module，在其中引用被测试 module）

```sh
vcs test.v      # 编译 verilog 产生二进制文件 simv
./simv          # 执行
```

vcs 查看波形

```sh
vcs -kdb -debug_access+all $verilog_files
./simv -gui     # 使用 dve 查看
./simv -verdi   # 使用 verdi 查看(推荐)
```

## verdi

命令行参数

|arg | desc
|- |-
|f/F    | 指定含有多个 verilog 文件路径的文件
|ssf    | 指定 fsdb/vcd 波形文件
|mdt    | 指定 mdt 文件
|sv     | 支持 system-verilog(IEEE 1800-2005)

### 基础用法

1.点击工具栏 New WaveForm
2.将 Instance 界面被测试 instance 拖动到 Waveform 界面
3.点击 Run Simulation 按钮开始测试
4.在 Waveform 界面查看波形
5.更多介绍查看 \<\<VCS QuickStart\>\> Setting up the simulation for debug 章节

## sdf 反标（sdf back-annotation）

[eetop](https://blog.eetop.cn/blog-934213-53717.html)

SDF文件里面包含了一些器件的固有延迟，内部连线的延迟，端口延迟，时序确认信息，时序约束信息和脉宽控制信息等内容。
VCS读取SDF文件实际上就是延迟信息的一个反标过程。VCS通过读取SDF文件里面的延迟值，从而改变原文件的默认延迟值（通常是由原文件默认指定，如果原文件没有指定那么就是采用仿真工具默认指定的延迟值）。

在 _test.v 中导入 sdf 文件:

```verilog
module test;
    initial begin
        $sdf_annotate("/tmp/xxx.sdf");
    end
endmodule
```

## 对比 netlist 检查逻辑功能是否一致

[netlist_compare](./netlist_compare/README.md) 如对比 verilog 网表和 spice/cdl 网表

## vcd/vcd+(vpd)

```sh
vcs -debug_access+all test.v
./simv
vpd2vcd vcdplus.vpd > test.vcd
vcd2vec -nvcd test.vcd -nsig test.sig -nvec test.vec
```

verilog 中需要添加代码

```verilog
module tmp();
    initial begin
        $vcdpluson();
    end
endmodule
```

test.sig 文件格式(# 不是注释)

```txt
#scope <module_name>
#vih 0.8
#vil 0
#voh 0.5
#vol 0.3
#trise 10ps
#tfall 10ps
#input ls
#input ds
#input sd
#input a[[6:0]]
#input ceb
#input web
#input ck
#output di[[15:0]]
#output do[[15:0]]
#tdelay 5.0n do[[15:0]]
```

## fsdb 波形文件

```sh
vcs -fsdb test.v
```

```verilog
initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars;
end
```
