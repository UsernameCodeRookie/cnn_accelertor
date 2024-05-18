module control_unit #(
    parameter WIDTH = 16,
    parameter SRAM_ADDR_WIDTH = 10
)(
    input clk,
    input rst_n,
    input start,

    // Matrix(kxm) * Matrix(mxn) = Matrix(kxn)
    input [WIDTH-1:0] k,
    input [WIDTH-1:0] m,
    input [WIDTH-1:0] n,

    output reg [SRAM_ADDR_WIDTH-1:0] filters_addr,
    output reg [SRAM_ADDR_WIDTH-1:0] ifmaps_addr,
    
    output reg enable_filters_to_sa,
    output reg enable_ifmaps_to_sa
);

    //sram ifmaps: (m+k) * m
    //sram filters: m * (n+m)
    //timing: 0->m+n+k
    reg [WIDTH-1:0] k_r;
    reg [WIDTH-1:0] m_r;
    reg [WIDTH-1:0] n_r;

    localparam IDLE = 0;
    localparam WORK = 1;
    localparam DONE = 2;

    reg [WIDTH-1:0] counter;
    reg [1:0] current_state;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            current_state <= IDLE;
            enable_filters_to_sa <= 0;
            enable_ifmaps_to_sa <= 0;

            filters_addr <= 0;
            ifmaps_addr <= 0;

            k_r <= 0;
            m_r <= 0;
            n_r <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start) begin
                        current_state <= WORK;
                        counter <= 0;
                        enable_filters_to_sa <= 1;
                        enable_ifmaps_to_sa <= 1;

                        filters_addr <= 0;
                        ifmaps_addr <= 0;

                        k_r <= k;
                        m_r <= m;
                        n_r <= n;
                    end
                end
                WORK: begin
                    counter <= counter + 1;
                    if (counter == m_r + k_r + n_r - 2) begin
                        current_state <= DONE;
                        enable_filters_to_sa <= 0;
                        enable_ifmaps_to_sa <= 0;
                    end

                    if (ifmaps_addr < m_r + k_r - 2) begin
                        ifmaps_addr <= ifmaps_addr + 1;
                    end else begin
                        enable_ifmaps_to_sa <= 0;
                    end

                    if (filters_addr < m_r + n_r - 2) begin
                        filters_addr <= filters_addr + 1;
                    end else begin
                        enable_filters_to_sa <= 0;
                    end
                end
                DONE: begin
                    current_state <= IDLE;

                    filters_addr <= 0;
                    ifmaps_addr <= 0;

                    k_r <= 0;
                    m_r <= 0;
                    n_r <= 0;
                end
            endcase
        end
    end

endmodule