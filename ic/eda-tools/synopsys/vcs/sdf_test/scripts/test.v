`timescale 1ns / 1ns

module and2(a, b, c, clk);
    input a, b, clk;
    output reg c;

    wire symbol_name1;
    wire symbol_name2;
    assign symbol_name1 = a ? 1'b0 : 1'b1;
    assign symbol_name2 = a ? 1'b0 : 1'b1;

    parameter C_DELAY = 5;

    always @(clk) begin

        # C_DELAY c = a & b;
        $display("%b %b %b", a, b, c);
    end

    specify

        //$setup(c, posedge clk, 2);
        //$hold(posedge clk, c, 2);

        // 设置默认 setup/hold 时序
        $setup(c, clk &&& symbol_name, 2);
        $hold(clk &&& symbol_name2, c, 2);

        //$setup(c, clk &&& a == 1'B1, 2);
        //$hold(clk &&& a == 1'B1, c, 2);
    endspecify

endmodule

module test();
    reg a, b;
    wire c;

    parameter CLK_SW = 10;

    reg clk;
    initial begin
        $sdf_annotate("./test.sdf");
        clk = 0;
        a = 1'b0;
        b = 1'b1;
        forever begin
            a = ~a;
            #CLK_SW clk = ~clk;
        end
    end

    initial #100 $finish;

    and2 ia(.a(a), .b(b), .c(c), .clk(clk));
endmodule
