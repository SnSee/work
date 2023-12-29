
# primetime

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
