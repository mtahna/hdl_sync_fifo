
### Interface 

|Parameter    | Default Value   | Description        |
|:------------|:---------------:|:-------------------|
|FIFO_DEPTH   |        4        | fifo depth (min:2) |
|DATA_WIDTH   |       16        | data width (min:1) |
|FWFT_MODE    |        1        | fifo read mode (1:first word fall-through fifo, 0:standard fifo) |

|Signal |I/O | Description        |
|:------|:--:|:-------------------|
|clk    | I  | clock              |
|rstn   | I  | reset (active low) |
|wen    | I  | write enable       |
|wdata  | I  | write data         |
|ren    | I  | read enable        |
|rdata  | O  | read data          |
|empty  | O  | fifo empty flag    |
|full   | O  | fifo full flag     |

### Block Diagram
This design is a synchronous FIFO with a common clock.
Depending on the parameter setting, FIFO depth, data width, and read mode can be specified.
Read pointer and Write pointer are implemented by one hot encoding.

<img src="https://github.com/mtahna/hdl/blob/master/verilog/sync_fifo/BlockDiagram.png" alt="Timing" title="Timing">

State transitions of read pointer and write pointer are shown below.

<img src="https://github.com/mtahna/hdl/blob/master/verilog/sync_fifo/PointerState.png" alt="Timing" title="Timing">

### Timing Chart
Enter wdata at the same time as wen=1.The write pointer is updated with wen=1.
In the read first-out mode (FWFT_MODE=1), the first read data is output two cycles after the first write.
ren = 1 is enabled to update the read pointer and output the next rdata.
When all FIFOs are filled, full=1.Empty=1 if the FIFO becomes empty.

<img src="https://github.com/mtahna/hdl/blob/master/verilog/sync_fifo/wave_fifo.png" alt="Timing" title="Timing">

```wavedrom
{ signal: [
    { name:'clk'  , wave: 'p..............' },
    { name:'wen'  , wave: '01.01.0........' },
    { name:'wdata', wave: 'x23x45x........', data: 'a b c d' },
    { name:'full' , wave: '0.....1.0......' },
    { name:'ren'  , wave: '0......1..0.10.' },
    { name:'rdata', wave: 'x..2....345..x.', data: 'a b c d' },
    { name:'empty', wave: '1..0.........1.' },
  ],
  head:{
    text:'Syncronized FIFO(FWFT_MODE=1, FIFO_DEPTH=4)',
    tick:0,
  },
}
```
