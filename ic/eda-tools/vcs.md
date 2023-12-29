
# vcs

vcs(Verilog Compiler Simulator) 是电路仿真验证工具，可以进行电路的时序模拟。可以借助 verdi 进行 debug.

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

# verdi
# 1.点击工具栏 New WaveForm
# 2.将 Instance 界面被测试 instance 拖动到 Waveform 界面
# 3.点击 Run Simulation 按钮开始测试
# 4.在 Waveform 界面查看波形
# 5.更多介绍查看 <<VCS QuickStart>> Setting up the simulation for debug 章节
```

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
