module sync_fifo #(
    parameter FIFO_DEPTH=4  , // fifo depth (fifo depth size >= 2)
    parameter DATA_WIDTH=16 , // data width (data bit size >= 1)
    parameter FWFT_MODE=1     // fifo read mode (1:first word fall-through fifo, 0:standard fifo)
)(
    input  wire                  clk     , // clock
    input  wire                  rstn    , // reset
    input  wire                  wen     , // write enable
    input  wire [DATA_WIDTH-1:0] wdata   , // write data
    input  wire                  ren     , // read enable
    output reg  [DATA_WIDTH-1:0] rdata   , // read data
    output reg                   empty   , // fifo empty flag
    output reg                   full      // fifo full flag
);

reg  [FIFO_DEPTH-1:0] wptr                ;
wire [FIFO_DEPTH-1:0] wptr_next           ;
reg  [FIFO_DEPTH-1:0] rptr                ;
wire [FIFO_DEPTH-1:0] rptr_next           ;
reg  [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

// write pointer onehot encoding
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wptr <= {{FIFO_DEPTH-1{1'b0}}, 1'b1};
    end else if (wen & (~full)) begin
        wptr <= {wptr[FIFO_DEPTH-1-1:0], wptr[FIFO_DEPTH-1]};
    end
end
assign wptr_next = {wptr[FIFO_DEPTH-1-1:0], wptr[FIFO_DEPTH-1]};

// read pointer onehot encoding
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rptr <= {{FIFO_DEPTH-1{1'b0}}, 1'b1};
    end else if (ren & (~empty)) begin
        rptr <= {rptr[FIFO_DEPTH-1-1:0], rptr[FIFO_DEPTH-1]};
    end
end
assign rptr_next = {rptr[FIFO_DEPTH-1-1:0], rptr[FIFO_DEPTH-1]};

// empty flag
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        empty <= 1'b1;
    end else begin
        if (empty) begin
            //if (wen) empty <= 1'b0;
            if (~(| (wptr & rptr))) empty <= 1'b0; // if (wptr != rptr) empty <= 1'b0;
        end else if((~empty) & (~full) & (~wen) & ren) begin
            empty <= | (wptr & rptr_next); // empty <= (wptr == rptr_next);
        end
    end
end

// full flag
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        full <= 1'b0;
    end else begin
        if (full) begin
            if (ren) full <= 1'b0;
        end else if ((~empty) & (~full) & wen & (~ren)) begin
            full <= | (wptr_next & rptr); // full <= (wptr_next == rptr);
        end
    end
end

// fifo write
generate
    genvar v_mem;
    for(v_mem=0; v_mem<FIFO_DEPTH; v_mem=v_mem+1) begin : g_wmem
        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                mem[v_mem] <= {DATA_WIDTH{1'b0}};
            end else if (wen & (~full) & wptr[v_mem]) begin
                mem[v_mem] <= wdata;
            end
        end
    end
endgenerate

// fifo read
generate
    genvar v_fd, v_dt;
    wire [FIFO_DEPTH-1:0]            read_sel;
    wire [FIFO_DEPTH*DATA_WIDTH-1:0] mem_flat;
    wire [DATA_WIDTH*FIFO_DEPTH-1:0] mem_flat_swap;

    if (FWFT_MODE != 0) begin : fwft // first word fall-through (FWFT)
        assign read_sel = (ren & (~empty)) ? rptr_next : rptr;
    end else begin : std             // standard mode
        assign read_sel = (ren & (~empty)) ? rptr : {FIFO_DEPTH{1'b0}};
    end

    for(v_fd=0; v_fd<FIFO_DEPTH; v_fd=v_fd+1) begin : g_rflat
        assign mem_flat[(v_fd+1)*DATA_WIDTH-1:v_fd*DATA_WIDTH] = {DATA_WIDTH{read_sel[v_fd]}} & mem[v_fd];
    end
    for(v_fd=0; v_fd<FIFO_DEPTH; v_fd=v_fd+1) begin : g_rswap_f
        for(v_dt=0; v_dt<DATA_WIDTH; v_dt=v_dt+1) begin : g_rswap_d
            assign mem_flat_swap[v_dt*FIFO_DEPTH+v_fd] = mem_flat[v_fd*DATA_WIDTH+v_dt];
        end
    end

    for(v_dt=0; v_dt<DATA_WIDTH; v_dt=v_dt+1) begin : g_rdata
        if (FWFT_MODE != 0) begin : fwft // first word fall-through (FWFT)
            always @(posedge clk or negedge rstn) begin
                if (!rstn) rdata[v_dt] <= 1'b0;
                else       rdata[v_dt] <= | mem_flat_swap[(v_dt+1)*FIFO_DEPTH-1:v_dt*FIFO_DEPTH];
            end
        end else begin : std             // standard mode
            always @(posedge clk or negedge rstn) begin
                if (!rstn)    rdata[v_dt] <= 1'b0;
                else if (ren) rdata[v_dt] <= | mem_flat_swap[(v_dt+1)*FIFO_DEPTH-1:v_dt*FIFO_DEPTH]; // rdata <= mem[rptr];
            end
        end
    end

endgenerate


endmodule