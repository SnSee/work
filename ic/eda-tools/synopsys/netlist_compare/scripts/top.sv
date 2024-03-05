`timescale 1ns/10ps

module top;
    parameter STIMU_WIDTH       = 1;
    parameter CAPTURE_WIDTH     = 1;
    parameter SEQ_LOGIC         = 0;
    parameter LAT_LOGIC         = 0;
    parameter LATX2_LOGIC       = 0;
    parameter PULSE_LATCH_LOGIC = 0;
    parameter INIT_ROUND        = 0;

    wire [CAPTURE_WIDTH - 1: 0] capture_ref;
    wire [CAPTURE_WIDTH - 1: 0] capture_duv;
    wire [STIMU_WIDTH: 0] stimu;
    wire clk;

    simu_gen #(
        .STIMU_WIDTH(STIMU_WIDTH),
        .CAPTURE_WIDTH(CAPTURE_WIDTH),
        .SEQ_LOGIC(SEQ_LOGIC),
        .LAT_LOGIC(LAT_LOGIC),
        .PULSE_LATCH_LOGIC(PULSE_LATCH_LOGIC),
        .INIT_ROUND(INIT_ROUND)
    ) u_simu_gen(.stimu(stimu), .clk(clk), .capture_ref(capture_ref), .capture_duv(capture_duv));

    // Instance of RTL
    generate
        if(SEQ_LOGIC && !LAT_LOGIC && !LATX2_LOGIC) begin
            ref_model #(STIMU_WIDTH, CAPTURE_WIDTH) u_ref(.stimu({clk, stimu[STIMU_WIDTH - 2: 0]}), .capture(capture_ref));
        end
        else if(LAT_LOGIC) begin
            ref_model #(STIMU_WIDTH, CAPTURE_WIDTH) u_ref(.stimu({stimu[STIMU_WIDTH - 2: 0], clk}), .capture(capture_ref));
        end
        else if(LATX2_LOGIC) begin
            ref_model #(STIMU_WIDTH, CAPTURE_WIDTH) u_ref(.stimu({clk, clk, stimu[STIMU_WIDTH - 3: 0]}), .capture(capture_ref));
        end
        else begin
            ref_model #(STIMU_WIDTH, CAPTURE_WIDTH) u_ref(.stimu(stimu[STIMU_WIDTH - 1: 0]), .capture(capture_ref));
        end
    endgenerate

    // Instance of Spice
    generate
        if(SEQ_LOGIC && !LAT_LOGIC && !LATX2_LOGIC) begin
            spice_duv #(STIMU_WIDTH, CAPTURE_WIDTH) u_duv(.stimu({clk, stimu[STIMU_WIDTH - 2: 0]}), .capture(capture_duv));
        end
        else if(LAT_LOGIC) begin
            spice_duv #(STIMU_WIDTH, CAPTURE_WIDTH) u_duv(.stimu({stimu[STIMU_WIDTH - 2: 0], clk}), .capture(capture_duv));
        end
        else if(LATX2_LOGIC) begin
            spice_duv #(STIMU_WIDTH, CAPTURE_WIDTH) u_duv(.stimu({clk, clk, stimu[STIMU_WIDTH - 3: 0]}), .capture(capture_duv));
        end
        else begin
            spice_duv #(STIMU_WIDTH, CAPTURE_WIDTH) u_duv(.stimu(stimu[STIMU_WIDTH - 1: 0]), .capture(capture_duv));
        end
    endgenerate

endmodule

module simu_gen #(
    parameter INC_STEP          = 1,
    parameter STIMU_WIDTH       = 1,
    parameter CAPTURE_WIDTH     = 1,
    parameter TO_CYCLES         = 300,
    parameter SEQ_LOGIC         = 0,
    parameter LAT_LOGIC         = 0,
    parameter PULSE_LATCH_LOGIC = 0,
    parameter INIT_ROUND        = 0
    ) (
        output reg [STIMU_WIDTH: 0] stimu,
        output clk,
        input [CAPTURE_WIDTH - 1: 0] capture_ref,
        input [CAPTURE_WIDTH - 1: 0] capture_duv
    );

    reg rst_n;
    reg gen_clk, gen_pulse_h, gen_pulse_l;
    reg start_compare;
    int match_cnt;
    int mismatch_cnt;

    generate
        if (PULSE_LATCH_LOGIC == 1) begin
            assign clk = gen_pulse_h;
        end
        else if (PULSE_LATCH_LOGIC == 2) begin
            assign clk = gen_pulse_l;
        end
        else begin
            assign clk = gen_clk;
        end
    endgenerate

    always @(negedge gen_clk or negedge rst_n) begin
        if(!rst_n) begin
            gen_pulse_l <= 1'b1;
            gen_pulse_h <= 1'b1;
        end
        else begin
            #5;
            gen_pulse_l <= 1'b0;
            gen_pulse_h <= 1'b1;
            #300ps;
            gen_pulse_l <= 1'b1;
            gen_pulse_h <= 1'b0;
        end
    end

    // 定义时钟
    initial begin
        gen_clk = 0;
        forever begin
            #10;
            gen_clk = ~gen_clk;
        end
    end

    integer fp;

    // 初始化变量
    initial begin
        rst_n = 0;
        start_compare = !INIT_ROUND;
        #1000;
        rst_n = 1;
        match_cnt = 0;
        mismatch_cnt = 0;

        // 开启多线程
        fork
            // 线程 1
            begin
                if(INIT_ROUND) begin
                    @(posedge stimu[STIMU_WIDTH]);
                end
                @(negedge gen_clk);             // 阻塞等待 gen_clk 到下降沿
                start_compare = 1;
                @(posedge stimu[STIMU_WIDTH]);
                repeat(3) @(posedge gen_clk);
            end

            // 线程 2
            repeat(TO_CYCLES) begin
                @(posedge gen_clk);
            end
        join_any    // 等待任一线程结束

        $display("Match Counts: %d", match_cnt);
        fp = $fopen("simu_verdict.log", "w");
        if(!SEQ_LOGIC && match_cnt >= 2**CAPTURE_WIDTH + 1 && mismatch_cnt == 0)
            $fdisplay(fp, "%0d, %0d, PASS", match_cnt, mismatch_cnt);
        else if(!SEQ_LOGIC)
            $fdisplay(fp, "%0d, %0d, FAIL", match_cnt, mismatch_cnt);
        else if(SEQ_LOGIC && match_cnt > CAPTURE_WIDTH && mismatch_cnt == 0)
            $fdisplay(fp, "%0d, %0d, PASS", match_cnt, mismatch_cnt);
        else
            $fdisplay(fp, "%0d, %0d, FAIL", match_cnt, mismatch_cnt);
        $fclose(fp);
        $finish;
    end

    
    always @(negedge gen_clk or negedge rst_n) begin
        if(!rst_n || stimu[STIMU_WIDTH] == 1'b1)
            stimu <= #100ps {(STIMU_WIDTH + 1){1'b0}};
        else
            stimu <= #100ps stimu + INC_STEP;
    end


    always @(posedge gen_clk or negedge rst_n) begin
        if(rst_n) begin
            if(start_compare == 1) begin
                assert(capture_duv == capture_ref) match_cnt += 1; else begin
                    mismatch_cnt += 1;
                    $display("ERROR !!! Comparing Mismatch: %h != %h", capture_ref, capture_duv);
                end
            end
        end
    end


    // 设置波形文件
    initial begin
        $fsdbDumpfile("vcs.fsdb");
        $fsdbDumpvars;
    end

endmodule
