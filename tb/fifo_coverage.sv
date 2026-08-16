`ifndef FIFO_COVERAGE_SV
`define FIFO_COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_if.sv"

class fifo_coverage extends uvm_component;
    virtual fifo_if vif;

    // ==========================================
    // 1. 写时钟域覆盖率组 (Write Domain)
    // ==========================================
    covergroup cg_write;                                           //创建一个覆盖率相机
        option.per_instance = 1;                                   //covergroup的自带变量，如果这个类被创建了多个实例（多个对象），每个对象单独统计自己的覆盖率，不合并。
        option.name = "cg_write";                                  //给这个“相机”起个名字，方便调试时看报告。

        // 1.1 覆盖写操作：是否发生过写，是否空闲过
        cp_winc: coverpoint vif.winc {                             //cp_winc：给这个覆盖点起的标签名。      coverpoint vif.winc：我要盯着 vif.winc（写使能信号，它是 0 或 1 的比特）。    
            bins write_active = {1};                               //定义了一个“桶”（bin），名字叫 write_active，只要信号的值等于 1，就丢进这个桶里计数。
            bins write_idle   = {0};                               //信号等于 0 时，丢进 write_idle 桶
        }
        
        // 1.2 覆盖满状态：是否达到过满状态
        cp_wfull: coverpoint vif.wfull {                           //cp_wfull：给这个覆盖点起的标签名。     coverpoint vif.wfull：我要盯着 vif.wfull（写满信号，它是 0 或 1 的比特）。
            bins not_full = {0};                                   //定义了一个“桶”（bin），名字叫 not_full，只要信号的值等于 0，就丢进这个桶里计数。
            bins full     = {1};                                   //信号等于 1 时，丢进 full 桶
        }
        
        // 1.3 极限状态翻转：证明 FIFO 确实在 满/不满 的边缘横跳过
        cp_wfull_trans: coverpoint vif.wfull {                     //cp_wfull_trans：给这个覆盖点起的标签名。coverpoint vif.wfull：我要盯着 vif.wfull（写满信号，它是 0 或 1 的比特）。
            bins full_to_not_full = (1 => 0);                      //这里的 => 是 SystemVerilog 的跳变运算符，代表“从 1 变成 0”。
            bins not_full_to_full = (0 => 1);                      //这里的 => 是 SystemVerilog 的跳变运算符，代表“从 0 变成 1”。
        }
        
        // 1.4 交叉覆盖：满状态与写操作的关系
        cr_winc_wfull: cross cp_winc, cp_wfull {                   //cr_winc_wfull:给这个覆盖点起的标签名。 cross cp_winc, cp_wfull：把前面两个覆盖点（写使能 和 满标志）组合起来，
                                                                   //形成一个表格（2x2=4种组合）。
            // 如果出现满的时候强行写，算作非法行为 (Driver应该挡住)
            illegal_bins illegal_write_when_full = binsof(cp_winc.write_active) && binsof(cp_wfull.full);
        }                                                          //illegal_bins:定义了一个“非法桶”。      binsof(cp_winc.write_active) && binsof(cp_wfull.full):写使能处于激活状态
                                                                   //且满标志处于满状态
    endgroup

    // ==========================================
    // 2. 读时钟域覆盖率组 (Read Domain)
    // ==========================================
    covergroup cg_read;                                            //创建一个读时钟域覆盖率组
        option.per_instance = 1;                                   //covergroup的自带变量，如果这个类被创建了多个实例（多个对象），每个对象单独统计自己的覆盖率，不合并。
        option.name = "cg_read";                                   //给这个“相机”起个名字，方便调试时看报告。

        cp_rinc: coverpoint vif.rinc {                             //cp_rinc:给这个覆盖点起的标签名。       coverpoint vif.rinc:我要盯着 vif.rinc（读使能信号，它是 0 或 1 的比特）。  
            bins read_active = {1};                                //定义了一个“桶”（bin），名字叫 read_active，只要信号的值等于 1，就丢进这个桶里计数。
            bins read_idle   = {0};                                //定义了一个“桶”（bin），名字叫 read_idle，只要信号的值等于 0，就丢进这个桶里计数。
        }
        cp_rempty: coverpoint vif.rempty {                         //cp_rempty:给这个覆盖点起的标签名。     coverpoint vif.rempty:我要盯着 vif.rempty（读空信号，它是 0 或 1 的比特）。
            bins not_empty = {0};                                  //定义了一个“桶”（bin），名字叫 not_empty，只要信号的值等于 0，就丢进这个桶里计数。
            bins empty     = {1};                                  //定义了一个“桶”（bin），名字叫 empty，只要信号的值等于 1，就丢进这个桶里计数。
        }
        cp_rempty_trans: coverpoint vif.rempty {                   //cp_rempty_trans:给这个覆盖点起的标签名。 coverpoint vif.rempty:我要盯着 vif.rempty（读空信号，它是 0 或 1 的比特）。
            bins empty_to_not_empty = (1 => 0);                    //这里的 => 是 SystemVerilog 的跳变运算符，代表“从 1 变成 0”。
            bins not_empty_to_empty = (0 => 1);                    //这里的 => 是 SystemVerilog 的跳变运算符，代表“从 0 变成 1”。
        }
        cr_rinc_rempty: cross cp_rinc, cp_rempty {                 //cr_rinc_rempty:给这个覆盖点起的标签名。 cross cp_rinc, cp_rempty：把前面两个覆盖点（读使能 和 空标志）组合起来，
                                                                   //形成一个表格（2x2=4种组合）。
            illegal_bins illegal_read_when_empty = binsof(cp_rinc.read_active) && binsof(cp_rempty.empty);
                                                                   //illegal_bins:定义了一个“非法桶”。     binsof(cp_rinc.read_active) && binsof(cp_rempty.empty):读使能处于激活状态
                                                                   //且空标志处于空状态
        }
    endgroup

    `uvm_component_utils(fifo_coverage)

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_write = new();
        cg_read  = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("FIFO_COV", "virtual interface must be set for vif!!!")
    endfunction

    // 自动采样线程
    virtual task main_phase(uvm_phase phase);
        super.main_phase(phase);
        fork
            // 写域自动拍照
            while(1) begin
                @(posedge vif.wclk);
                if(vif.wrst_n === 1'b1) cg_write.sample();          // 调用覆盖率组的 sample() 方法，拍一张快照
            end
            
            // 读域自动拍照
            while(1) begin
                @(posedge vif.rclk);
                if(vif.rrst_n === 1'b1) cg_read.sample();           // 拍读域的快照
            end
        join
    endtask

    // 【极其惊艳的一手】：在仿真结束时，自动在控制台打印出覆盖率分数！
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COVERAGE", "==================================================", UVM_NONE)                            //UVM_NONE 表示无论仿真设置多安静，这行都必须打印出来。
        `uvm_info("COVERAGE", $sformatf("=> Write Port Coverage: %0.2f %%", cg_write.get_inst_coverage()), UVM_NONE)     //$sformatf(...)：SystemVerilog 的格式化字符
        `uvm_info("COVERAGE", "==================================================", UVM_NONE)                            //串函数，和 C 语言的 printf 一样
    endfunction                                                     //cg_write.get_inst_coverage()：调用覆盖率组的方法，返回一个 0 到 100 的实数，表示这个组的覆盖率百分比。

endclass

`endif