module sram #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 10) (
    input clk,
    input we,

    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
    end

    assign dout = mem[addr];

endmodule