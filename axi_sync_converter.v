module axi_sync_converter (
    input  wire clk,
    input  wire reset_n,

    input  wire [63:0] axi_awaddr,
    input  wire axi_awvalid,
    output wire axi_awready,
    input  wire [63:0] axi_wdata,
    input  wire [7:0] axi_wstrb,
    input  wire axi_wvalid,
    output wire axi_wready,
    output wire [1:0] axi_bresp,
    output wire axi_bvalid,
    input  wire axi_bready,
    input  wire [63:0] axi_araddr,
    input  wire axi_arvalid,
    output wire axi_arready,
    output wire [63:0] axi_rdata,
    output wire [1:0] axi_rresp,
    output wire axi_rvalid,
    input  wire axi_rready,

    output wire en,
    output wire we,
    output wire [63:0] addr,
    input  wire [63:0] rdata,
    output wire [63:0] wdata
);

reg accept_read;
reg [1:0] ren_reg;
wire ren = axi_arvalid && accept_read;
wire [63:0] raddr = axi_araddr;

assign axi_arready = 1'b1;
assign axi_rdata = rdata;
assign axi_rresp = 2'b00;  // always OK
assign axi_rvalid = ren_reg[0];

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        accept_read = 1'b1;
        ren_reg = 2'b0;
    end else begin
        ren_reg <= {ren_reg, ren};
        
        if (axi_rvalid) begin
            accept_read = 1'b1;
        end else if (ren) begin
            accept_read = 1'b0;
        end
    end
end

reg [63:0] waddr_reg;
wire awen = axi_awvalid && axi_awready;

reg accept_write;
reg [1:0] wen_reg;
wire wen = axi_wvalid && accept_write;
wire [63:0] waddr = waddr_reg;
assign wdata = axi_wdata;

assign axi_awready = 1'b1;
assign axi_wready = wen_reg[0];
assign axi_bresp = 2'b00;  // always OK
assign axi_bvalid = wen_reg[1];

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        accept_write = 1'b1;
        waddr_reg = 64'h0;
        wen_reg = 2'b0;
    end else begin
        if (awen) begin
            waddr_reg <= axi_awaddr;
        end
        
        wen_reg <= {wen_reg, wen};
        if (axi_wready) begin
            accept_write = 1'b1;
        end else if (wen) begin
            accept_write = 1'b0;
        end
    end
end

assign en = ren || wen;
assign we = wen;
assign addr = wen ? waddr : raddr;

endmodule
