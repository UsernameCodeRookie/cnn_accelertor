module gemm #(
    parameter WIDTH = 16,
    parameter SRAM_ADDR_WIDTH = 10,
    parameter I = 4, // number of rows
    parameter J = 4  // number of columns
)(
    input clk,
    input rst_n,
    input start,

    input [WIDTH-1:0] k,
    input [WIDTH-1:0] m,
    input [WIDTH-1:0] n
);

    wire sram_filters_we;
    wire [SRAM_ADDR_WIDTH-1:0] sram_filters_addr;
    wire [J * WIDTH-1:0] sram_filters_din = 0;
    wire [J * WIDTH-1:0] sram_filters_dout;

    sram #(
        .DATA_WIDTH(J * WIDTH),
        .ADDR_WIDTH(SRAM_ADDR_WIDTH)
    ) sram_filters (
        .clk(clk),
        .we(sram_filters_we),

        .addr(sram_filters_addr),
        .din(sram_filters_din),
        .dout(sram_filters_dout)
    );

    wire sram_ifmaps_we;
    wire [SRAM_ADDR_WIDTH-1:0] sram_ifmaps_addr;
    wire [I * WIDTH-1:0] sram_ifmaps_din = 0;
    wire [I * WIDTH-1:0] sram_ifmaps_dout;

    sram #(
        .DATA_WIDTH(I * WIDTH),
        .ADDR_WIDTH(SRAM_ADDR_WIDTH)
    ) sram_ifmaps (
        .clk(clk),
        .we(sram_ifmaps_we),

        .addr(sram_ifmaps_addr),
        .din(sram_ifmaps_din),
        .dout(sram_ifmaps_dout)
    );

    wire cu_start = start;
    wire [WIDTH-1:0] cu_k = k;
    wire [WIDTH-1:0] cu_m = m;
    wire [WIDTH-1:0] cu_n = n;

    wire cu_enable_filters_to_sa;
    wire cu_enable_ifmaps_to_sa;
    wire [SRAM_ADDR_WIDTH-1:0] cu_filters_addr;
    wire [SRAM_ADDR_WIDTH-1:0] cu_ifmaps_addr;

    assign sram_filters_addr = cu_filters_addr;
    assign sram_ifmaps_addr = cu_ifmaps_addr;

    control_unit #(
        .WIDTH(WIDTH),
        .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH)
    ) cu (
        .clk(clk),
        .rst_n(rst_n),
        .start(cu_start),

        .k(cu_k),
        .m(cu_m),
        .n(cu_n),

        .filters_addr(cu_filters_addr),
        .ifmaps_addr(cu_ifmaps_addr),
        .enable_filters_to_sa(cu_enable_filters_to_sa),
        .enable_ifmaps_to_sa(cu_enable_ifmaps_to_sa)
    );


    wire [J * WIDTH-1:0] sa_in_north = cu_enable_filters_to_sa ? sram_filters_dout : 0;
    wire [I * WIDTH-1:0] sa_in_west = cu_enable_ifmaps_to_sa ? sram_ifmaps_dout : 0;

    systolic_array #(
        .WIDTH(WIDTH),
        .I(I),
        .J(J)
    ) sa (
        .in_north(sa_in_north),
        .in_west(sa_in_west),

        .result(),

        .rst_n(rst_n),
        .clk(clk)
    );



endmodule