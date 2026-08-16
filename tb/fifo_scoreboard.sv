`ifndef FIFO_SCOREBOARD_SV
`define FIFO_SCOREBOARD_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_transaction.sv"

class fifo_scoreboard extends uvm_scoreboard;
    fifo_transaction exp_que[$];
    fifo_transaction act_que[$];

    uvm_blocking_get_port #(fifo_transaction) expect_port;
    uvm_blocking_get_port #(fifo_transaction) actual_port;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void build_phase(uvm_phase phase);

    `uvm_component_utils(fifo_scoreboard)
endclass

function void fifo_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    expect_port = new("expect_port", this);
    actual_port = new("actual_port", this);
endfunction

task fifo_scoreboard::main_phase(uvm_phase phase);
    fifo_transaction get_expect, get_actual, temp_tran_exp, temp_tran_act;
    bit result;
    super.main_phase(phase);
    fork
        while(1)begin
            expect_port.get(get_expect);
            exp_que.push_back(get_expect);
        end
        while(1)begin
            actual_port.get(get_actual);
            act_que.push_back(get_actual);
        end
        while(1)begin                                              
            wait((exp_que.size() > 0) && (act_que.size() > 0));
            temp_tran_exp = exp_que.pop_front();
            temp_tran_act = act_que.pop_front();
            if(temp_tran_exp.rdata == temp_tran_act.rdata)
                result = 1;
            else
                result = 0;
            if(result)begin
                `uvm_info("fifo_scoreboard", "Compare SUCCESSFUL", UVM_LOW);
            end
            else begin
                `uvm_error("fifo_scoreboard", "Compare FAILED");
                $display("the expect pkt is");
                temp_tran_exp.print();
                $display("the actual pkt is");
                temp_tran_act.print();
            end
        end
    join
endtask

`endif