
# verilog

模型假设

> 模型假设（Modeling Assumptions）是指在建立电路仿真模型时所假设的一些条件和规定，这些条件和规定主要是为了保证该模型能够正确地进行仿真和验证，从而达到设计电路的目的。在 Verilog 文件的开头通常会列出该模型的假设条件和规定，方便使用者使用和理解该模型。常见的模型假设包括支持的仿真方式、支持的数据类型、模型中时序信息的处理方式、信号的响应特性等等。

`timescale

```verilog
// 设置时间单位和精度
// timeunit     : times 和 delays 时间单位
// timeprecision: delay 精度，在 simulation 前 delay 值会被精确到该单位
//                即使其他地方有更小的精度，也会精确到该单位
`timescale timeunit / timeprecision
```

`define

```verilog
// 预处理指令，可以理解为 C 语言的 #define 宏
`define name value
// 引用宏
`name

// 加法宏
`define ADD(x, y) ((x) + (y))

reg [7:0] a=2;
reg [7:0] b=3;
reg [7:0] sum;
sum = `ADD(a,b);    // 调用加法宏函数计算 a 和 b 的和
```

条件编译指令

```verilog
`ifdef DEBUG_MODE
  module test_module;
    ...
  endmodule
`else
  ...
`endif
```

定义模块

```verilog
// D 触发器
module D_FF(CLK, D, Q);             // 定义模块(module)及端口(pin/port)
    input D;                        // 输入信号
    input CLK;                      // 时钟
    output Q;                       // 输出信号
    reg Q;                          // 寄存器或状态变量

    // 只要 CLK 变为上升沿(从 0 变为 1)就执行
    // always 表示该语句会一直执行
    // @(posedge CLK) 表示上升沿条件
    always @(posedge CLK) begin     
        Q <= D;
    end
endmodule
```

always @

```verilog
// @ 符号被称为“敏感词”，用于指定变量的敏感事件，从而建立时序逻辑电路
// @ 符号通常用于组合语句 always@( ) ，用于指定需要监听的变量或事件
// @ 符号后面用括号包围一个事件列表，用于指定某个条件的变化会触发该组合语句的执行
// @ 符号只能用于时序逻辑电路的描述中，无法用于组合逻辑电路的描述

// 该组合语句会在 clk 信号上升沿到来时执行更新操作
always @(posedge clk) 

// 如果我们希望监听多个变量或事件，可以使用逗号分隔它们
// 该组合语句会在 a、b 或 c 的值发生变化时执行更新操作
always @(a, b, c)
```

数字表示方法

```verilog
// 未设置位宽的数字
659             // 十进制
'h837FF        // 十六进制
'o7460          // 八进制
4af             // 非法

// 设置位宽的数字
4'b1001         // 4-bit 二进制
5'D3            // 5-bit 十进制
3'b01x          // 3-bit 二进制但是最后一位值未知
12'hx           // 12-bit 未知数

// high-impedance number（高阻抗数字）是一种特殊的数字类型
// 用于表示信号处于高阻抗状态
// 通常用于描述某些未连接部件的输出信号或者模拟电路中的开路状态
// 在进行计算时会产生严格的限制，并且不能与其他类型的数字进行运算
16'hz           // 16-bit 高阻抗数字

// 正负符号
8'd-6           // 非法
-8'd6           // 8-bit 十进制负数
```

parameter

```verilog
module test();
    parameter msb = 7;                  // 声明
    // 引用宏
    `name
    parameter e = 25, f = 9;            // 同时声明两个变量
    parameter r = 5.7;                  // 声明 r 为 real parameter
    parameter bs = 8,
              bs_mask = bs - 1;         // 使用变量赋值
    
    parameter [3:0] mux = 0;
    parameter real rl = 3.5e17;
    parameter p1 = 13'h7e;
    parameter [31:0] dec_const = 1'b1;  // 会自动转换为 32-bit
    parameter newconst = 3'h4           // 隐式 3-bit
endmodule
```

===

```verilog
// === 不仅会比较值，还会比较数据类型和位宽，都相同返回 true，否则 false
module example(input [3:0] A, input [3:0] B);

    // 当 A 和 B 完全相等时，输出结果为 true
    assign result1 = (A === B);    
    
    // 当 A 和 B 的值不完全相等时，输出结果为 false
    // 3'b101 表示 3bit 二进制数，其值为 101
    // 4'h5 表示 4bit 十六进制数，其值为 5
    assign result2 = (A[2:0] === 3'b101) && (B === 4'h5);
    
endmodule
```

内置门

```verilog
// x: 信号值未知或未定义
// z: 信号处于高阻抗状态，即未连接到任何有效电路或信号源

and  a1(out, in1, in2);         // 与门
nand n1(out, in1, in2);         // 与非门
or   o1(out, in1, in2);         // 或门
nor  n2(out, in1, in2);         // 或非门
xor  x2(out, in1, in2);         // 异或门
xnor x1(out, in1, in2);         // 同或门

not n1(out1, out2, in);
buf b1(out1, out2, in);
```
