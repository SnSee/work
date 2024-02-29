
# primetime

## commands

### set_clock_latency / set_clock_uncertainty

**clock latency** 是 clock source 到 endpoint 花费的时间. **endpoint** 一般是用于时钟同步的 clock pins. 同一个 clock source 可以有多个 endpoint, 共同组成一个 **clock tree**，clock tree 中对应多个 endpoint 有多个 latency(延时), 每个 endpoint 延迟也会由于时钟抖动或其他原因出现波动, 最大延迟和最小延迟差值称作 **clock skew**.

```tcl
set_clock_latency 2.2 [get_clocks BZCLK]
# Both rise and fall latency is 2.2ns.
# Use options -rise and -fall if different.

# uncertainty = clock-jitter + clock-skew + additional-pessimism
set_clock_latency 2.0 [get_clocks USBCLK]
set_clock_uncertainty 0.2 [get_clocks USBCLK]
# The 200ps may be composed of 50ps clock jitter,
# 100ps clock skew and 50ps additional pessimism.
```

### set_false_path

If indeed there are data paths that cross between clock domains, a decision has to be made as to whether the paths are real or not. An example of a real path is a flip-flop with a 2x speed clock driving into a flip-flop with a 1x speed clock. An example of a **false path** is where the designer has explicitly placed clock synchronizer logic between the two clock domains. In this case, even though there appears to be a timing path from one clock domain to the next, it is not a real timing path since the data is not constrained to propagate through the synchronizer logic in one clock cycle. Such a path is referred to as a false path - not real - because the clock synchronizer ensures that the data passes correctly from one domain to the next.

当数据传输路径从一个时钟域(clock domain)到另一个时钟域时，如果连接两个时钟域的是一个时钟同步器，则由时钟同步器来保证时序正确。跨越这两个时钟域之间的传输路径被称作 **false path**.

```tcl
set_false_path -from [get_clocks USBCLK] -to [get_clocks MEMCLK]
```

### set_operating_conditions: 设置 PVT

```tcl
set_operating_conditions "WCCOM" -library mychip
# Use the operating condition called WCCOM defined in the
# cell library mychip.
```

### set_wire_load_model: 设置 wire-load 模型

```tcl
set_wire_load_model “wlm_cons” -library “lib_stdcell”
# Says to use the wireload model wlm_cons present in the
# cell library lib_stdcell.
```

### set_wire_load_mode: 设置 wire-load 模式

```tcl
set_wire_load_mode enclosed
# top:
# enclosed:
# segmented:
```

## 从 liberty 中提取 sdf

```verilog
// top.v
module top(CK, A, DI, DO);
    input CK, A, DI;
    output DO;
    // 假设 liberty 中 cell 名为 test
    test U_t(.CK(CK), .A(A), .DI(DI), .DO(DO));
endmodule
```

```tcl
# extract_sdf.tcl
read_lib test.lib
# verilog 可以根据 liberty 自己写，只需要在 top module 中包含 cell 名称对应的 instance 即可
read_verilog top.v
write_sdf -levels 1 -no_edge_merging {cell_delays timing_checks} -version 3.0 -context verilog test.sdf
exit
```

```sh
# run
primetime -file extract_sdf.tcl
```
