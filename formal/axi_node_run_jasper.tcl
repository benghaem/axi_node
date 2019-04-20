
# Load sources
analyze -sv src/apb_regs_top.sv \
    src/axi_address_decoder_AR.sv \
    src/axi_address_decoder_AW.sv \
    src/axi_address_decoder_BR.sv \
    src/axi_address_decoder_BW.sv \
    src/axi_address_decoder_DW.sv \
    src/axi_AR_allocator.sv \
    src/axi_ArbitrationTree.sv \
    src/axi_AW_allocator.sv \
    src/axi_BR_allocator.sv \
    src/axi_BW_allocator.sv \
    src/axi_DW_allocator.sv \
    src/axi_FanInPrimitive_Req.sv \
    src/axi_multiplexer.sv \
    src/axi_node.sv \
    src/axi_node_intf_wrap.sv \
    src/axi_node_wrap_with_slices.sv \
    src/axi_regs_top.sv \
    src/axi_request_block.sv \
    src/axi_response_block.sv \
    src/axi_RR_Flag_Req.sv \
    deps/common_cells/src/fifov2.sv
 

# Elaborate
elaborate -top axi_node

# Setup clock and reset
clock clk
reset -expression !rst_n

#run
prove -bg all

