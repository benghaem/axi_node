#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2015.09
# platform  : Linux 4.9.0-8-amd64
# version   : 2015.09 FCS 64 bits
# build date: 2015.09.29 22:07:32 PDT
#----------------------------------------
# started Sat Apr 20 12:40:06 CDT 2019
# hostname  : daffy
# pid       : 24153
# arguments : '-label' 'session_0' '-console' 'daffy:45881' '-style' 'windows' '-proj' '/home/polaris/bghaem/verif/axi_node/formal/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/polaris/bghaem/verif/axi_node/formal/jgproject/.tmp/.initCmds.tcl' 'axi_node_run_jasper.tcl'

# Load sources
analyze -sv ../src/apb_regs_top.sv \
    ../src/axi_address_decoder_AR.sv \
    ../src/axi_address_decoder_AW.sv \
    ../src/axi_address_decoder_BR.sv \
    ../src/axi_address_decoder_BW.sv \
    ../src/axi_address_decoder_DW.sv \
    ../src/axi_AR_allocator.sv \
    ../src/axi_ArbitrationTree.sv \
    ../src/axi_AW_allocator.sv \
    ../src/axi_BR_allocator.sv \
    ../src/axi_BW_allocator.sv \
    ../src/axi_DW_allocator.sv \
    ../src/axi_FanInPrimitive_Req.sv \
    ../src/axi_multiplexer.sv \
    ../src/axi_node.sv \
    ../src/axi_node_intf_wrap.sv \
    ../src/axi_node_wrap_with_slices.sv \
    ../src/axi_regs_top.sv \
    ../src/axi_request_block.sv \
    ../src/axi_response_block.sv \
    ../src/axi_RR_Flag_Req.sv \
    ../deps/common_cells/src/fifo_v2.sv \
    ../deps/common_cells/src/fifo_v3.sv \
    ../deps/axi/src/axi_intf.sv
