`ifndef FIFO_IF_SV
`define FIFO_IF_SV

interface fifo_if(input wclk, input rclk, input wrst_n, input rrst_n);
    parameter DSIZE = 8;
    
    logic             winc;      //使能
    logic [DSIZE-1:0] wdata;
    logic             wfull;

    logic             rinc;      //使能
    logic [DSIZE-1:0] rdata;
    logic             rempty;
endinterface

`endif