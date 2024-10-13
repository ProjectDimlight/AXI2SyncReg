module test_reg (
    input  wire clk,
    input  wire reset_n,

    input  wire en,
    input  wire we,
    input  wire [63:0] addr,
    output wire [63:0] rdata,
    input  wire [63:0] wdata
);

reg [63:0] cnt;
reg run;
reg [63:0] rdata_reg;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cnt = 64'h0;
        run = 1'b0;
    end else begin
        cnt <= run ? cnt + 1 : cnt;
        if (en) begin
            if (we) begin
                if (addr[31:0] == 32'h8000_0000) begin
                    cnt <= wdata;
                end else if (addr[31:0] == 32'h8000_0008) begin
                    run <= wdata[0];
                end else if (addr[31:0] == 32'h8000_0010) begin
                    cnt <= cnt + wdata;
                end
            end
        end
    end
end

assign rdata = rdata_reg;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        rdata_reg = 64'h0;
    end else begin
        if (addr[31:0] == 32'h8000_0000) begin
            rdata_reg <= cnt;
        end else if (addr[31:0] == 32'h8000_0008) begin
            rdata_reg <= {63'b0, run};
        end else begin
            rdata_reg <= 0;
        end
    end
end

endmodule