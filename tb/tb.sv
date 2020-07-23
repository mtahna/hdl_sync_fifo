`timescale 1ns/1ps
module tb ();

localparam FIFO_DEPTH=4        ;
localparam DATA_WIDTH=16       ;
localparam FWFT_MODE=1         ;

logic                  clk     ; // clock
logic                  rstn    ; // reset
logic                  wen     ; // write enable
logic [DATA_WIDTH-1:0] wdata   ; // write data
logic                  ren     ; // read enable
logic [DATA_WIDTH-1:0] rdata   ; // read data
logic                  empty   ; // fifo empty flag
logic                  full    ; // fifo full flag

sync_fifo #(
    .FIFO_DEPTH  (FIFO_DEPTH  ), // addr width
    .DATA_WIDTH  (DATA_WIDTH  ), // data width
    .FWFT_MODE   (FWFT_MODE   )  // fifo read mode
) ufifo (
    .clk         (clk         ), // input  wire                  clock
    .rstn        (rstn        ), // input  wire                  reset
    .wen         (wen         ), // input  wire                  write enable
    .wdata       (wdata       ), // input  wire [DATA_WIDTH-1:0] write data
    .ren         (ren         ), // input  wire                  read enable
    .rdata       (rdata       ), // output reg  [DATA_WIDTH-1:0] read data
    .empty       (empty       ), // output reg                   fifo empty flag
    .full        (full        )  // output reg                   fifo full flag
);

initial begin
    clk = 1;
    forever #1000 clk = ~clk;
end

initial begin
    rstn = 0; wen = 0; ren = 0;
    repeat(10) @(posedge clk);
    rstn = 1;
    repeat(10) @(posedge clk);

    @(posedge clk); #1; wen = 1'b1; wdata = 16'h1111;
    @(posedge clk); #1; wen = 1'b0;

    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b0;

    @(posedge clk); #1; wen = 1'b1; wdata = 16'h2222;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h3333;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h4444;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h5555;
    @(posedge clk); #1; wen = 1'b0;

    @(posedge clk); #1; ren = 1'b1; $display("RDATA=%8x.",rdata);
    @(posedge clk); #1; ren = 1'b1; $display("RDATA=%8x.",rdata);
    @(posedge clk); #1; ren = 1'b1; $display("RDATA=%8x.",rdata);
    @(posedge clk); #1; ren = 1'b1; $display("RDATA=%8x.",rdata);
    @(posedge clk); #1; ren = 1'b0; $display("RDATA=%8x.",rdata);

    @(posedge clk); #1; wen = 1'b1; wdata = 16'h6666;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h7777;
    @(posedge clk); #1; wen = 1'b0;
    repeat(5) @(posedge clk);
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b0;

    @(posedge clk); #1; wen = 1'b1; wdata = 16'h8888;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h9999;
    @(posedge clk); #1; wen = 1'b0;

    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b0;

    @(posedge clk); #1; wen = 1'b1; wdata = 16'hAAAA;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'hBBBB;
    @(posedge clk); #1; wen = 1'b0;

    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b0;

    @(posedge clk); #1; wen = 1'b1; wdata = 16'hCCCC;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'hDDDD;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'hEEEE;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'hFFFF;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0123;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h4567;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h89AB;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'hCDEF;
    @(posedge clk); #1; wen = 1'b0;

    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b1;
    @(posedge clk); #1; ren = 1'b0;

    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0000; ren = 1'b0;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0001; ren = 1'b0;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0002; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0003; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0004; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0005; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0006; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0007; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b0;                   ren = 1'b1;
    @(posedge clk); #1;                               ren = 1'b1;
    @(posedge clk); #1;                               ren = 1'b0;

    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0008; ren = 1'b0;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h0009; ren = 1'b0;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h000A; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h000B; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h000C; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h000D; ren = 1'b1;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h000E; ren = 1'b0;
    @(posedge clk); #1; wen = 1'b1; wdata = 16'h000F; ren = 1'b0;
    @(posedge clk); #1; wen = 1'b0;                   ren = 1'b0;
    @(posedge clk); #1;                               ren = 1'b0;
    @(posedge clk); #1;                               ren = 1'b0;
    @(posedge clk); #1;                               ren = 1'b1;
    @(posedge clk); #1;                               ren = 1'b1;
    @(posedge clk); #1;                               ren = 1'b1;
    @(posedge clk); #1;                               ren = 1'b1;

    repeat(10) @(posedge clk);
    $finish;
end

endmodule