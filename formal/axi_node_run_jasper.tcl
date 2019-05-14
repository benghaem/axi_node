
# Load sources
analyze -sv ../src/apb_regs_top.sv \
    ../deps/axi/src/axi_pkg.sv \
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
    ../src/axi_node_wrap_with_slices.sv \
    ../src/axi_regs_top.sv \
    ../src/axi_request_block.sv \
    ../src/axi_response_block.sv \
    ../src/axi_RR_Flag_Req.sv \
    ../deps/common_cells/src/deprecated/fifo_v2.sv \
    ../deps/common_cells/src/fifo_v3.sv \
    ../formal/axi_intf_for_test.sv \
    ../formal/axi_node_intf_wrap_for_test.sv
 

# Elaborate
elaborate -top axi_node_intf_wrap

# Setup clock and reset
clock clk
#reset -init_state reset_values.txt
reset -expression ~rst_n

#run
prove -bg -all

