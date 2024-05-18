module systolic_array #(
    parameter WIDTH = 16,
    parameter I = 4, // number of rows
    parameter J = 4  // number of columns
)(
    input [J * WIDTH-1:0] in_north,
    input [I * WIDTH-1:0] in_west,

    output [2 * WIDTH * I * J -1:0] result,
    
    input rst_n,
    input clk
);

    wire [WIDTH-1:0] pe_out_south_w [I-1:0][J-1:0];
    wire [WIDTH-1:0] pe_out_east_w [I-1:0][J-1:0];


    genvar i, j;
    generate
        for (i = 0; i < I; i = i + 1) begin : rows
            for (j = 0; j < J; j = j + 1) begin : cols
                processing_element #(.WIDTH(WIDTH)) inst (
                    .in_north(i > 0 ? pe_out_south_w[i-1][j] : in_north[(J-j) * WIDTH-1 -: WIDTH]), // connect to the south output of the row above
                    .in_west(j > 0 ? pe_out_east_w[i][j-1] : in_west[(I-i) * WIDTH-1 -: WIDTH]), // connect to the east output of the column to the left
                    
                    .out_south(pe_out_south_w[i][j]),
                    .out_east(pe_out_east_w[i][j]),

                    .result(result[2 * WIDTH * (i * J + j) +: 2 * WIDTH]),

                    .ena(1'b1),
                    .rst_n(rst_n),
                    .clk(clk)
                );
            end
        end
    endgenerate

endmodule