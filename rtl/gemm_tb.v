`timescale 1ns / 1ps

module gemm_tb;

    parameter WIDTH = 16;
    parameter SRAM_ADDR_WIDTH = 10;
    parameter PE_ARRAY_I = 20; // I -> K, J -> N
    parameter PE_ARRAY_J = 20;

    parameter GEMM_K = 18;
    parameter GEMM_M = 12;
    parameter GEMM_N = 4;

    reg clk;
    reg rst_n;
    reg start;
    reg [15:0] k, m, n;

    // Instantiate the gemm module
    gemm #(
        .WIDTH(WIDTH),
        .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH),
        .I(PE_ARRAY_I),
        .J(PE_ARRAY_J)
    ) gemm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .k(k),
        .m(m),
        .n(n)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        $readmemh("data/_filters.txt", gemm_inst.sram_filters.mem);
        $readmemh("data/_ifmaps.txt", gemm_inst.sram_ifmaps.mem);
        $dumpfile("gemm_tb.vcd");
        $dumpvars(0, gemm_tb);

        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        k = 16'h0;
        m = 16'h0;
        n = 16'h0;

        #10;
        rst_n = 1;
        #10;
        start = 1;
        k = GEMM_K;
        m = GEMM_M;
        n = GEMM_N;

        #10;
        start = 0;

        // Add more test sequences as needed

        #1000;
        $finish;
    end

endmodule