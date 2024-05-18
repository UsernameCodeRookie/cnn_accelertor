module processing_element #(
    parameter WIDTH = 16
)(
    input [WIDTH-1:0] in_north,
    input [WIDTH-1:0] in_west,

    output reg [WIDTH-1:0] out_south,
    output reg [WIDTH-1:0] out_east,

    output reg [2 * WIDTH-1:0] result,
    input ena,

    input rst_n,
    input clk
);

    wire [2 * WIDTH-1:0] multi;

    assign multi = in_north * in_west;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            out_east <= 0;
            out_south <= 0;
            result <= 0;
        end
        else if(ena) begin
            out_east <= in_west;
            out_south <= in_north;
            result <= result + multi;
        end
    end
    
endmodule