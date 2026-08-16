`ifndef FIFO_TRANSACTION_SV
`define FIFO_TRANSACTION_SV
import uvm_pkg::*;
`include "uvm_macros.svh"

class fifo_transaction extends uvm_sequence_item;
    parameter DSIZE = 8;
    typedef enum bit [1:0]{            //定义一个表示状态的变量
        WRITE = 2'b00,                 //写状态
        READ  = 2'b01,                 //读状态
        IDLE  = 2'b10                  //空闲状态
    } op_e;

    rand op_e            op;

    rand bit [DSIZE-1:0] wdata;

    bit      [DSIZE-1:0] rdata;


    constraint op_e_cons{
        if(op != WRITE)
        {
            wdata == 0;
        }
    }

    function new(string name = "fifo_transaction");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(fifo_transaction)
        `uvm_field_enum(op_e, op, UVM_ALL_ON)
        `uvm_field_int(wdata,     UVM_ALL_ON)
        `uvm_field_int(rdata,     UVM_ALL_ON)
    `uvm_object_utils_end
endclass

`endif