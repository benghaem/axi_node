// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module axi_node_intf_wrap #(
    parameter NB_MASTER      = 4,
    parameter NB_SLAVE       = 2,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 10,
    parameter AXI_USER_WIDTH = 0
  )(
    // Clock and Reset
    input logic clk,
    input logic rst_n,
    input logic test_en_i,

    AXI_BUS.Slave slave[NB_SLAVE-1:0],
    AXI_BUS.Master master[NB_MASTER-1:0],

    // Memory map
    input  logic [NB_MASTER-1:0][AXI_ADDR_WIDTH-1:0]  start_addr_i,
    input  logic [NB_MASTER-1:0][AXI_ADDR_WIDTH-1:0]  end_addr_i
  );

  localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH/8;
  localparam NB_REGION      = 1;

  // AXI ID WIDTHs for master and slave IPS
  localparam AXI_ID_WIDTH_TARG =   AXI_ID_WIDTH;
  localparam AXI_ID_WIDTH_INIT =   AXI_ID_WIDTH_TARG + $clog2(NB_SLAVE);


  // Signals to slave periperhals
  logic [NB_MASTER-1:0][AXI_ID_WIDTH_INIT-1:0] s_master_aw_id;
  logic [NB_MASTER-1:0][AXI_ADDR_WIDTH-1:0]    s_master_aw_addr;
  logic [NB_MASTER-1:0][7:0]                   s_master_aw_len;
  logic [NB_MASTER-1:0][2:0]                   s_master_aw_size;
  logic [NB_MASTER-1:0][1:0]                   s_master_aw_burst;
  logic [NB_MASTER-1:0]                        s_master_aw_lock;
  logic [NB_MASTER-1:0][3:0]                   s_master_aw_cache;
  logic [NB_MASTER-1:0][2:0]                   s_master_aw_prot;
  logic [NB_MASTER-1:0][3:0]                   s_master_aw_region;
  logic [NB_MASTER-1:0][AXI_USER_WIDTH-1:0]    s_master_aw_user;
  logic [NB_MASTER-1:0][3:0]                   s_master_aw_qos;
  logic [NB_MASTER-1:0]                        s_master_aw_valid;
  logic [NB_MASTER-1:0]                        s_master_aw_ready;

  logic [NB_MASTER-1:0][AXI_ID_WIDTH_INIT-1:0] s_master_ar_id;
  logic [NB_MASTER-1:0][AXI_ADDR_WIDTH-1:0]    s_master_ar_addr;
  logic [NB_MASTER-1:0][7:0]                   s_master_ar_len;
  logic [NB_MASTER-1:0][2:0]                   s_master_ar_size;
  logic [NB_MASTER-1:0][1:0]                   s_master_ar_burst;
  logic [NB_MASTER-1:0]                        s_master_ar_lock;
  logic [NB_MASTER-1:0][3:0]                   s_master_ar_cache;
  logic [NB_MASTER-1:0][2:0]                   s_master_ar_prot;
  logic [NB_MASTER-1:0][3:0]                   s_master_ar_region;
  logic [NB_MASTER-1:0][AXI_USER_WIDTH-1:0]    s_master_ar_user;
  logic [NB_MASTER-1:0][3:0]                   s_master_ar_qos;
  logic [NB_MASTER-1:0]                        s_master_ar_valid;
  logic [NB_MASTER-1:0]                        s_master_ar_ready;

  logic [NB_MASTER-1:0][AXI_DATA_WIDTH-1:0]    s_master_w_data;
  logic [NB_MASTER-1:0][AXI_STRB_WIDTH-1:0]    s_master_w_strb;
  logic [NB_MASTER-1:0]                        s_master_w_last;
  logic [NB_MASTER-1:0][AXI_USER_WIDTH-1:0]    s_master_w_user;
  logic [NB_MASTER-1:0]                        s_master_w_valid;
  logic [NB_MASTER-1:0]                        s_master_w_ready;

  logic [NB_MASTER-1:0][AXI_ID_WIDTH_INIT-1:0] s_master_b_id;
  logic [NB_MASTER-1:0][1:0]                   s_master_b_resp;
  logic [NB_MASTER-1:0]                        s_master_b_valid;
  logic [NB_MASTER-1:0][AXI_USER_WIDTH-1:0]    s_master_b_user;
  logic [NB_MASTER-1:0]                        s_master_b_ready;

  logic [NB_MASTER-1:0][AXI_ID_WIDTH_INIT-1:0] s_master_r_id;
  logic [NB_MASTER-1:0][AXI_DATA_WIDTH-1:0]    s_master_r_data;
  logic [NB_MASTER-1:0][1:0]                   s_master_r_resp;
  logic [NB_MASTER-1:0]                        s_master_r_last;
  logic [NB_MASTER-1:0][AXI_USER_WIDTH-1:0]    s_master_r_user;
  logic [NB_MASTER-1:0]                        s_master_r_valid;
  logic [NB_MASTER-1:0]                        s_master_r_ready;

  // Signals from AXI masters
  logic [NB_SLAVE-1:0][AXI_ID_WIDTH_TARG-1:0] s_slave_aw_id;
  logic [NB_SLAVE-1:0][AXI_ADDR_WIDTH-1:0]    s_slave_aw_addr;
  logic [NB_SLAVE-1:0][7:0]                   s_slave_aw_len;
  logic [NB_SLAVE-1:0][2:0]                   s_slave_aw_size;
  logic [NB_SLAVE-1:0][1:0]                   s_slave_aw_burst;
  logic [NB_SLAVE-1:0]                        s_slave_aw_lock;
  logic [NB_SLAVE-1:0][3:0]                   s_slave_aw_cache;
  logic [NB_SLAVE-1:0][2:0]                   s_slave_aw_prot;
  logic [NB_SLAVE-1:0][3:0]                   s_slave_aw_region;
  logic [NB_SLAVE-1:0][AXI_USER_WIDTH-1:0]    s_slave_aw_user;
  logic [NB_SLAVE-1:0][3:0]                   s_slave_aw_qos;
  logic [NB_SLAVE-1:0]                        s_slave_aw_valid;
  logic [NB_SLAVE-1:0]                        s_slave_aw_ready;

  logic [NB_SLAVE-1:0][AXI_ID_WIDTH_TARG-1:0] s_slave_ar_id;
  logic [NB_SLAVE-1:0][AXI_ADDR_WIDTH-1:0]    s_slave_ar_addr;
  logic [NB_SLAVE-1:0][7:0]                   s_slave_ar_len;
  logic [NB_SLAVE-1:0][2:0]                   s_slave_ar_size;
  logic [NB_SLAVE-1:0][1:0]                   s_slave_ar_burst;
  logic [NB_SLAVE-1:0]                        s_slave_ar_lock;
  logic [NB_SLAVE-1:0][3:0]                   s_slave_ar_cache;
  logic [NB_SLAVE-1:0][2:0]                   s_slave_ar_prot;
  logic [NB_SLAVE-1:0][3:0]                   s_slave_ar_region;
  logic [NB_SLAVE-1:0][AXI_USER_WIDTH-1:0]    s_slave_ar_user;
  logic [NB_SLAVE-1:0][3:0]                   s_slave_ar_qos;
  logic [NB_SLAVE-1:0]                        s_slave_ar_valid;
  logic [NB_SLAVE-1:0]                        s_slave_ar_ready;

  logic [NB_SLAVE-1:0][AXI_DATA_WIDTH-1:0]    s_slave_w_data;
  logic [NB_SLAVE-1:0][AXI_STRB_WIDTH-1:0]    s_slave_w_strb;
  logic [NB_SLAVE-1:0]                        s_slave_w_last;
  logic [NB_SLAVE-1:0][AXI_USER_WIDTH-1:0]    s_slave_w_user;
  logic [NB_SLAVE-1:0]                        s_slave_w_valid;
  logic [NB_SLAVE-1:0]                        s_slave_w_ready;

  logic [NB_SLAVE-1:0][AXI_ID_WIDTH_TARG-1:0] s_slave_b_id;
  logic [NB_SLAVE-1:0][1:0]                   s_slave_b_resp;
  logic [NB_SLAVE-1:0]                        s_slave_b_valid;
  logic [NB_SLAVE-1:0][AXI_USER_WIDTH-1:0]    s_slave_b_user;
  logic [NB_SLAVE-1:0]                        s_slave_b_ready;

  logic [NB_SLAVE-1:0][AXI_ID_WIDTH_TARG-1:0] s_slave_r_id;
  logic [NB_SLAVE-1:0][AXI_DATA_WIDTH-1:0]    s_slave_r_data;
  logic [NB_SLAVE-1:0][1:0]                   s_slave_r_resp;
  logic [NB_SLAVE-1:0]                        s_slave_r_last;
  logic [NB_SLAVE-1:0][AXI_USER_WIDTH-1:0]    s_slave_r_user;
  logic [NB_SLAVE-1:0]                        s_slave_r_valid;
  logic [NB_SLAVE-1:0]                        s_slave_r_ready;

  // Signals Used to configure the AXI node
  logic [NB_REGION-1:0][NB_MASTER-1:0][AXI_ADDR_WIDTH-1:0] s_start_addr;
  logic [NB_REGION-1:0][NB_MASTER-1:0][AXI_ADDR_WIDTH-1:0] s_end_addr;
  logic [NB_REGION-1:0][NB_MASTER-1:0]                     s_valid_rule;
  logic [NB_SLAVE-1:0][NB_MASTER-1:0]                      s_connectivity_map;


  generate
    genvar i;
    for(i = 0; i < NB_MASTER; i++)
    begin
      assign                        master[i].aw_id[AXI_ID_WIDTH_INIT-1:0] = s_master_aw_id[i];
      assign                        master[i].aw_addr                      = s_master_aw_addr[i];
      assign                        master[i].aw_len                       = s_master_aw_len[i];
      assign                        master[i].aw_size                      = s_master_aw_size[i];
      assign                        master[i].aw_burst                     = s_master_aw_burst[i];
      assign                        master[i].aw_lock                      = s_master_aw_lock[i];
      assign                        master[i].aw_cache                     = s_master_aw_cache[i];
      assign                        master[i].aw_prot                      = s_master_aw_prot[i];
      assign                        master[i].aw_region                    = s_master_aw_region[i];
      assign                        master[i].aw_user                      = s_master_aw_user[i];
      assign                        master[i].aw_qos                       = s_master_aw_qos[i];
      assign                        master[i].aw_valid                     = s_master_aw_valid[i];
      assign s_master_aw_ready[i] = master[i].aw_ready;

      assign                        master[i].ar_id[AXI_ID_WIDTH_INIT-1:0] = s_master_ar_id[i];
      assign                        master[i].ar_addr                      = s_master_ar_addr[i];
      assign                        master[i].ar_len                       = s_master_ar_len[i];
      assign                        master[i].ar_size                      = s_master_ar_size[i];
      assign                        master[i].ar_burst                     = s_master_ar_burst[i];
      assign                        master[i].ar_lock                      = s_master_ar_lock[i];
      assign                        master[i].ar_cache                     = s_master_ar_cache[i];
      assign                        master[i].ar_prot                      = s_master_ar_prot[i];
      assign                        master[i].ar_region                    = s_master_ar_region[i];
      assign                        master[i].ar_user                      = s_master_ar_user[i];
      assign                        master[i].ar_qos                       = s_master_ar_qos[i];
      assign                        master[i].ar_valid                     = s_master_ar_valid[i];
      assign s_master_ar_ready[i] = master[i].ar_ready;

      assign                        master[i].w_data  = s_master_w_data[i];
      assign                        master[i].w_strb  = s_master_w_strb[i];
      assign                        master[i].w_last  = s_master_w_last[i];
      assign                        master[i].w_user  = s_master_w_user[i];
      assign                        master[i].w_valid = s_master_w_valid[i];
      assign s_master_w_ready[i]  = master[i].w_ready;

      assign s_master_b_id[i]     = master[i].b_id[AXI_ID_WIDTH_INIT-1:0];
      assign s_master_b_resp[i]   = master[i].b_resp;
      assign s_master_b_valid[i]  = master[i].b_valid;
      assign s_master_b_user[i]   = master[i].b_user;
      assign                        master[i].b_ready = s_master_b_ready[i];

      assign s_master_r_id[i]     = master[i].r_id[AXI_ID_WIDTH_INIT-1:0];
      assign s_master_r_data[i]   = master[i].r_data;
      assign s_master_r_resp[i]   = master[i].r_resp;
      assign s_master_r_last[i]   = master[i].r_last;
      assign s_master_r_user[i]   = master[i].r_user;
      assign s_master_r_valid[i]  = master[i].r_valid;
      assign                        master[i].r_ready = s_master_r_ready[i];

      assign s_start_addr[0][i] = start_addr_i[i];
      assign s_end_addr[0][i]   = end_addr_i[i];
    end
  endgenerate

  generate
    genvar j;
    for(j = 0; j < NB_SLAVE; j++)
    begin
      assign s_slave_aw_id[j]     = slave[j].aw_id[AXI_ID_WIDTH_TARG-1:0];
      assign s_slave_aw_addr[j]   = slave[j].aw_addr;
      assign s_slave_aw_len[j]    = slave[j].aw_len;
      assign s_slave_aw_size[j]   = slave[j].aw_size;
      assign s_slave_aw_burst[j]  = slave[j].aw_burst;
      assign s_slave_aw_lock[j]   = slave[j].aw_lock;
      assign s_slave_aw_cache[j]  = slave[j].aw_cache;
      assign s_slave_aw_prot[j]   = slave[j].aw_prot;
      assign s_slave_aw_region[j] = slave[j].aw_region;
      assign s_slave_aw_user[j]   = slave[j].aw_user;
      assign s_slave_aw_qos[j]    = slave[j].aw_qos;
      assign s_slave_aw_valid[j]  = slave[j].aw_valid;
      assign                        slave[j].aw_ready = s_slave_aw_ready[j];

      assign s_slave_ar_id[j]     = slave[j].ar_id[AXI_ID_WIDTH_TARG-1:0];
      assign s_slave_ar_addr[j]   = slave[j].ar_addr;
      assign s_slave_ar_len[j]    = slave[j].ar_len;
      assign s_slave_ar_size[j]   = slave[j].ar_size;
      assign s_slave_ar_burst[j]  = slave[j].ar_burst;
      assign s_slave_ar_lock[j]   = slave[j].ar_lock;
      assign s_slave_ar_cache[j]  = slave[j].ar_cache;
      assign s_slave_ar_prot[j]   = slave[j].ar_prot;
      assign s_slave_ar_region[j] = slave[j].ar_region;
      assign s_slave_ar_user[j]   = slave[j].ar_user;
      assign s_slave_ar_qos[j]    = slave[j].ar_qos;
      assign s_slave_ar_valid[j]  = slave[j].ar_valid;
      assign                        slave[j].ar_ready = s_slave_ar_ready[j];

      assign s_slave_w_data[j]    = slave[j].w_data;
      assign s_slave_w_strb[j]    = slave[j].w_strb;
      assign s_slave_w_last[j]    = slave[j].w_last;
      assign s_slave_w_user[j]    = slave[j].w_user;
      assign s_slave_w_valid[j]   = slave[j].w_valid;
      assign                        slave[j].w_ready = s_slave_w_ready[j];

      assign                        slave[j].b_id[AXI_ID_WIDTH_TARG-1:0] = s_slave_b_id[j];
      assign                        slave[j].b_resp                      = s_slave_b_resp[j];
      assign                        slave[j].b_valid                     = s_slave_b_valid[j];
      assign                        slave[j].b_user                      = s_slave_b_user[j];
      assign s_slave_b_ready[j]   = slave[j].b_ready;

      assign                        slave[j].r_id[AXI_ID_WIDTH_TARG-1:0] = s_slave_r_id[j];
      assign                        slave[j].r_data                      = s_slave_r_data[j];
      assign                        slave[j].r_resp                      = s_slave_r_resp[j];
      assign                        slave[j].r_last                      = s_slave_r_last[j];
      assign                        slave[j].r_user                      = s_slave_r_user[j];
      assign                        slave[j].r_valid                     = s_slave_r_valid[j];
      assign s_slave_r_ready[j]   = slave[j].r_ready;
    end
  endgenerate

  axi_node
  #(
    .AXI_ADDRESS_W      ( AXI_ADDR_WIDTH    ),
    .AXI_DATA_W         ( AXI_DATA_WIDTH    ),
    .N_MASTER_PORT      ( NB_MASTER         ),
    .N_SLAVE_PORT       ( NB_SLAVE          ),
    .AXI_ID_IN          ( AXI_ID_WIDTH_TARG ),
    .AXI_USER_W         ( AXI_USER_WIDTH    ),
    .N_REGION           ( NB_REGION         )
  )
  axi_node_i
  (
    .clk                    ( clk                ),
    .rst_n                  ( rst_n              ),
    .test_en_i              ( test_en_i          ),

    .slave_awid_i           ( s_slave_aw_id      ),
    .slave_awaddr_i         ( s_slave_aw_addr    ),
    .slave_awlen_i          ( s_slave_aw_len     ),
    .slave_awsize_i         ( s_slave_aw_size    ),
    .slave_awburst_i        ( s_slave_aw_burst   ),
    .slave_awlock_i         ( s_slave_aw_lock    ),
    .slave_awcache_i        ( s_slave_aw_cache   ),
    .slave_awprot_i         ( s_slave_aw_prot    ),
    .slave_awregion_i       ( s_slave_aw_region  ),
    .slave_awqos_i          ( s_slave_aw_qos     ),
    .slave_awuser_i         ( s_slave_aw_user    ),
    .slave_awvalid_i        ( s_slave_aw_valid   ),
    .slave_awready_o        ( s_slave_aw_ready   ),

    .slave_wdata_i          ( s_slave_w_data     ),
    .slave_wstrb_i          ( s_slave_w_strb     ),
    .slave_wlast_i          ( s_slave_w_last     ),
    .slave_wuser_i          ( s_slave_w_user     ),
    .slave_wvalid_i         ( s_slave_w_valid    ),
    .slave_wready_o         ( s_slave_w_ready    ),

    .slave_bid_o            ( s_slave_b_id       ),
    .slave_bresp_o          ( s_slave_b_resp     ),
    .slave_buser_o          ( s_slave_b_user     ),
    .slave_bvalid_o         ( s_slave_b_valid    ),
    .slave_bready_i         ( s_slave_b_ready    ),

    .slave_arid_i           ( s_slave_ar_id      ),
    .slave_araddr_i         ( s_slave_ar_addr    ),
    .slave_arlen_i          ( s_slave_ar_len     ),
    .slave_arsize_i         ( s_slave_ar_size    ),
    .slave_arburst_i        ( s_slave_ar_burst   ),
    .slave_arlock_i         ( s_slave_ar_lock    ),
    .slave_arcache_i        ( s_slave_ar_cache   ),
    .slave_arprot_i         ( s_slave_ar_prot    ),
    .slave_arregion_i       ( s_slave_ar_region  ),
    .slave_aruser_i         ( s_slave_ar_user    ),
    .slave_arqos_i          ( s_slave_ar_qos     ),
    .slave_arvalid_i        ( s_slave_ar_valid   ),
    .slave_arready_o        ( s_slave_ar_ready   ),

    .slave_rid_o            ( s_slave_r_id       ),
    .slave_rdata_o          ( s_slave_r_data     ),
    .slave_rresp_o          ( s_slave_r_resp     ),
    .slave_rlast_o          ( s_slave_r_last     ),
    .slave_ruser_o          ( s_slave_r_user     ),
    .slave_rvalid_o         ( s_slave_r_valid    ),
    .slave_rready_i         ( s_slave_r_ready    ),

    .master_awid_o          ( s_master_aw_id     ),
    .master_awaddr_o        ( s_master_aw_addr   ),
    .master_awlen_o         ( s_master_aw_len    ),
    .master_awsize_o        ( s_master_aw_size   ),
    .master_awburst_o       ( s_master_aw_burst  ),
    .master_awlock_o        ( s_master_aw_lock   ),
    .master_awcache_o       ( s_master_aw_cache  ),
    .master_awprot_o        ( s_master_aw_prot   ),
    .master_awregion_o      ( s_master_aw_region ),
    .master_awqos_o         ( s_master_aw_qos    ),
    .master_awuser_o        ( s_master_aw_user   ),
    .master_awvalid_o       ( s_master_aw_valid  ),
    .master_awready_i       ( s_master_aw_ready  ),

    .master_wdata_o         ( s_master_w_data    ),
    .master_wstrb_o         ( s_master_w_strb    ),
    .master_wlast_o         ( s_master_w_last    ),
    .master_wuser_o         ( s_master_w_user    ),
    .master_wvalid_o        ( s_master_w_valid   ),
    .master_wready_i        ( s_master_w_ready   ),

    .master_bid_i           ( s_master_b_id      ),
    .master_bresp_i         ( s_master_b_resp    ),
    .master_buser_i         ( s_master_b_user    ),
    .master_bvalid_i        ( s_master_b_valid   ),
    .master_bready_o        ( s_master_b_ready   ),

    .master_arid_o          ( s_master_ar_id     ),
    .master_araddr_o        ( s_master_ar_addr   ),
    .master_arlen_o         ( s_master_ar_len    ),
    .master_arsize_o        ( s_master_ar_size   ),
    .master_arburst_o       ( s_master_ar_burst  ),
    .master_arlock_o        ( s_master_ar_lock   ),
    .master_arcache_o       ( s_master_ar_cache  ),
    .master_arprot_o        ( s_master_ar_prot   ),
    .master_arregion_o      ( s_master_ar_region ),
    .master_aruser_o        ( s_master_ar_user   ),
    .master_arqos_o         ( s_master_ar_qos    ),
    .master_arvalid_o       ( s_master_ar_valid  ),
    .master_arready_i       ( s_master_ar_ready  ),

    .master_rid_i           ( s_master_r_id      ),
    .master_rdata_i         ( s_master_r_data    ),
    .master_rresp_i         ( s_master_r_resp    ),
    .master_rlast_i         ( s_master_r_last    ),
    .master_ruser_i         ( s_master_r_user    ),
    .master_rvalid_i        ( s_master_r_valid   ),
    .master_rready_o        ( s_master_r_ready   ),

    .cfg_START_ADDR_i       ( s_start_addr       ),
    .cfg_END_ADDR_i         ( s_end_addr         ),
    .cfg_valid_rule_i       ( s_valid_rule       ),
    .cfg_connectivity_map_i ( s_connectivity_map )
  );


  assign s_valid_rule       = '1;
  assign s_connectivity_map = '1;





//
//  ___ ___  ___ __  __   _   _       ___ ___  _  _ ___ ___ ___ 
// | __/ _ \| _ \  \/  | /_\ | |     / __/ _ \| \| | __|_ _/ __|
// | _| (_) |   / |\/| |/ _ \| |__  | (_| (_) | .` | _| | | (_ |
// |_| \___/|_|_\_|  |_/_/ \_\____|  \___\___/|_|\_|_| |___\___|
//
//

//SLAVE RESPONSE TIME
localparam SL_RT = 3;
localparam MX_BURST = 2;

//
//  __  __ __  __   _   ___     _   ___ ___ _   _ __  __ ___
// |  \/  |  \/  | /_\ | _ \   /_\ / __/ __| | | |  \/  | __|
// | |\/| | |\/| |/ _ \|  _/  / _ \\__ \__ \ |_| | |\/| | _|
// |_|  |_|_|  |_/_/ \_\_|   /_/ \_\___/___/\___/|_|  |_|___|
//
//

parameter mm_start = 32'h0000;
parameter mm_len = 32'h1000;

integer start_addr[NB_MASTER-1:0] ;
integer end_addr[NB_MASTER-1:0];
integer mm_end;

always @(posedge clk) begin
    if (!rst_n) begin
        integer i;
        integer tmp_addr; 
        tmp_addr = mm_start;
        for (i = 0; i < NB_MASTER; i++)
        begin
            start_addr[i] = tmp_addr;
            tmp_addr = tmp_addr + mm_len;
            end_addr[i] = tmp_addr-1;
        end
        mm_end = tmp_addr;
    end
end

generate
    genvar i;
    for (i = 0; i < NB_MASTER; i++)
    begin
        assume property( @(posedge clk) start_addr_i[i] == start_addr[i] );
        assume property( @(posedge clk) end_addr_i[i] == end_addr[i]);
    end
endgenerate

//Check for equality between a and b
property prop_eq(a,b);
    @(posedge clk) disable iff(!rst_n)
    a == b;
endproperty

//Signal is within correct range
property correct_address(addr_sig);
    @(posedge clk) disable iff(!rst_n)
    addr_sig < mm_end && addr_sig > mm_start;
endproperty

//Signal does not set the high bits of the id high (which are resevered for the
//interconnect)
property correct_id(id_sig);
    @(posedge clk) disable iff(!rst_n)
        id_sig <= 2**AXI_ID_WIDTH -1;
endproperty

//Signal a implies another signal is stable
property a_imp_stable(sig_a, sig_stable);
    @(posedge clk) disable iff(!rst_n)
    sig_a |-> $stable(sig_stable);
endproperty


generate
    genvar j;
    for (j = 0; j < NB_SLAVE; j++)
    begin
        correct_addr_ar: assume property(correct_address(slave[j].ar_addr));
        correct_addr_aw: assume property(correct_address(slave[j].aw_addr));
        correct_id_ar: assume property(correct_id(slave[j].ar_id));
        correct_id_aw: assume property(correct_id(slave[j].aw_id));
        zero_region_ar: assume property(prop_eq(slave[j].ar_region,0));
        zero_region_aw: assume property(prop_eq(slave[j].aw_region,0));
    end
endgenerate




//    _   ___ ___ _   _ __  __ ___
//   /_\ / __/ __| | | |  \/  | __|
//  / _ \\__ \__ \ |_| | |\/| | _|
// /_/ \_\___/___/\___/|_|  |_|___|
//





generate
    genvar k;
    for (k = 0; k < NB_MASTER; k++)
    begin
        reset_ar: assume property(@(posedge clk) 
            $past(!rst_n) |-> $past(!master[k].ar_ready));
        reset_aw: assume property(@(posedge clk) 
            $rose(rst_n) |-> $past(!master[k].aw_ready));
        reset_w: assume property(@(posedge clk) 
            $rose(rst_n) |-> $past(!master[k].w_ready));

        reset_valid_ar_a: assume property(@(posedge clk) 
            $rose(rst_n) |-> $past(master[j].ar_valid == 0));
        reset_valid_aw_a: assume property(@(posedge clk) 
            $rose(rst_n) |-> $past(master[j].aw_valid == 0));
        reset_valid_w_a: assume property(@(posedge clk) 
            $rose(rst_n) |-> $past(master[j].w_valid == 0));

        reset_b_val: assume property(@(posedge clk)
            $rose(rst_n) |-> $past(master[k].w_valid == 0));
        reset_r_val: assume property(@(posedge clk)
            $rose(rst_n) |-> $past(master[k].r_valid == 0));

        functional_slave_ar: assume property(@(posedge clk) disable iff(!rst_n)
            $fell(master[k].ar_ready) |-> ##[0:SL_RT] $rose(master[k].ar_ready));
        functional_slave_aw: assume property(@(posedge clk) disable iff(!rst_n)
            $fell(master[k].aw_ready) |-> ##[0:SL_RT] $rose(master[k].aw_ready));
    end
endgenerate

generate
    genvar j;
    for (j = 0; j < NB_SLAVE; j++)
    begin

        reset_ar_val: assume property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> $past(!slave[j].ar_valid));
        reset_aw_val: assume property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> $past(!slave[j].aw_valid));
        reset_w_val: assume property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> $past(!slave[j].w_valid));


        reset_b: assume property(@(posedge clk)
            $rose(rst_n) |-> $past(slave[j].w_ready == 0));
        reset_r: assume property(@(posedge clk)
            $rose(rst_n) |-> $past(slave[j].r_ready == 0));


        // Valid should remain high until the cycle after ready is asserted
        handshake_m_ar_0: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].ar_valid && !slave[j].ar_ready |=> slave[j].ar_valid);
        handshake_m_aw_0: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].aw_valid && !slave[j].aw_ready |=> slave[j].aw_valid);
        handshake_m_aw_1: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].aw_valid && slave[j].aw_ready |=> $fell(slave[j].aw_valid));
        handshake_m_w_0: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].w_valid && !slave[j].w_ready |=> slave[j].w_valid);

	
	// Valid should fall after seeing a ready
	handshake_m_ar_v: assume property(@(posedge clk) disable iff(!rst_n)
		slave[j].ar_ready && slave[j].ar_valid |=> $fell(slave[j].ar_valid));


        // Addresses should remain stable
        const_m_ar_id: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_id));
        const_m_ar_addr: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_addr));
        const_m_ar_len: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_len));
        const_m_ar_size: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_size));
        const_m_ar_burst: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_burst));
        const_m_ar_lock: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_lock));
        const_m_ar_cache: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_cache));
        const_m_ar_prot: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_prot));
        const_m_ar_qos: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_qos));
        const_m_ar_region: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_region));
        const_m_ar_user: assume property(a_imp_stable(slave[j].ar_valid, slave[j].ar_user));

        const_m_aw_id: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_id));
        const_m_aw_addr: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_addr));
        const_m_aw_len: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_len));
        const_m_aw_size: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_size));
        const_m_aw_burst: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_burst));
        const_m_aw_lock: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_lock));
        const_m_aw_cache: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_cache));
        const_m_aw_prot: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_prot));
        const_m_aw_qos: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_qos));
        const_m_aw_region: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_region));
        const_m_aw_user: assume property(a_imp_stable(slave[j].aw_valid, slave[j].aw_user));

        const_m_w_user: assume property(a_imp_stable(slave[j].w_valid, slave[j].w_user));

    end
endgenerate


//
//  ___ _   _ ___  ___ _____    ___ _____ ___ _
// | _ ) | | | _ \/ __|_   _|  / __|_   _| _ \ |
// | _ \ |_| |   /\__ \ | |   | (__  | | |   / |__
// |___/\___/|_|_\|___/ |_|    \___| |_| |_|_\____|
//
//
generate
    genvar j;
    for (j = 0; j < NB_SLAVE; j++)
    begin

    assume property(@(posedge clk) disable iff (!rst_n)
        $rose(slave[j].aw_valid) |=> slave[j].w_valid);

    assume property(@(posedge clk) disable iff (!rst_n)
        slave[j].w_valid |-> ##[0:MX_BURST] slave[j].w_last ##1 !slave[j].w_valid);

    assume property(@(posedge clk) disable iff (!rst_n)
        !slave[j].w_valid |-> !slave[j].w_last);

    assume property(@(posedge clk) disable iff (!rst_n)
        slave[j].w_valid |-> slave[j].aw_valid);

    assume property(@(posedge clk) disable iff (!rst_n)
        $fell(slave[j].w_valid) |-> $past($rose(slave[j].w_last)));

    assume property(@(posedge clk) disable iff (!rst_n)
        slave[j].w_last |=> !slave[j].w_valid);

    assume property(@(posedge clk) disable iff(!rst_n)
        slave[j].w_last |=> $rose(slave[j].b_valid));

    assume property(@(posedge clk) disable iff(!rst_n)
        slave[j].w_valid |-> !slave[j].b_valid);

    assume property(@(posedge clk) disable iff(!rst_n)
        slave[j].b_valid && !slave[j].b_ready |=> slave[j].b_valid);
    end

endgenerate

generate
    genvar k;
    for (k = 0; k < NB_MASTER; k++)
    begin
    assume property(@(posedge clk) disable iff(!rst_n)
        master[k].aw_ready |-> master[k].w_ready);
    end
endgenerate



//    _   ___ ___ ___ ___ _____
//   /_\ / __/ __| __| _ \_   _|
//  / _ \\__ \__ \ _||   / | |
// /_/ \_\___/___/___|_|_\ |_|
//

//Reset Assertions
generate
    genvar j;
    for (j = 0; j < NB_MASTER; j++)
    begin
        reset_valid_ar: assert property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> (master[j].ar_valid == 0));
        reset_valid_aw: assert property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> (master[j].aw_valid == 0));
        reset_valid_w: assert property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> (master[j].w_valid == 0));
    end
endgenerate

generate
    genvar i;
    for (i = 0; i < NB_SLAVE; i++)
    begin
        reset_valid_r: assert property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> (slave[i].r_valid == 0));
        reset_valid_b: assert property(@(posedge clk) disable iff(!rst_n)
            $past(!rst_n) |-> (slave[i].b_valid == 0));
    end
endgenerate


generate
    genvar j, k;

    for (k = 0; k < NB_MASTER; k++)
    begin
        for (j = 0; j < NB_SLAVE; j++)
        begin
            valid_master_iface_ar: assert property(@(posedge clk) disable iff(!rst_n) 
            slave[j].ar_valid && slave[j].ar_addr < end_addr[k] && slave[j].ar_addr >= start_addr[k] |-> ##[0:SL_RT+1] master[k].ar_valid );
            
            valid_master_iface_aw: assert property(@(posedge clk) disable iff(!rst_n) 
            slave[j].aw_valid && slave[j].aw_addr < end_addr[k] && slave[j].aw_addr >= start_addr[k] |-> ##[0:SL_RT] master[k].aw_valid );

            id_master_iface_ar: assert property(@(posedge clk) disable iff(!rst_n)
            (slave[j].ar_valid && slave[j].ar_addr < end_addr[k] && slave[j].ar_addr >= start_addr[k]) |-> ##[0:SL_RT] (master[k].ar_id == {j[0],slave[j].ar_id[AXI_ID_WIDTH-1:0]}) );
            
            id_master_iface_aw: assert property(@(posedge clk) disable iff(!rst_n)
            (slave[j].aw_valid && slave[j].aw_addr < end_addr[k] && slave[j].aw_addr >= start_addr[k]) |-> ##[0:SL_RT] (master[k].aw_id == {j[0],slave[j].aw_id[AXI_ID_WIDTH-1:0]}) );
        end
    end
endgenerate

//RR assertions
//at every master node on the interface, we will keep track of the requests it has from the slave nodes in a bitmap manner.
//for example at master node 1, if there are outstanding requests from slave ports 2 and 3, then pending_reqs[1][2] and pending_reqs[1][3] = 1.
//most_recent_gnt[0] will be a onehot vector indicating which slave port had the last access to the master.
//Need this for every channel -> Yes
logic [NB_MASTER-1:0][NB_SLAVE-1:0] ar_pending_reqs;
logic [NB_MASTER-1:0][NB_SLAVE-1:0] ar_most_recent_gnt;
integer onehot_ar_gnt[NB_MASTER];

logic [NB_MASTER-1:0][NB_SLAVE-1:0] aw_pending_reqs;
logic [NB_MASTER-1:0][NB_SLAVE-1:0] aw_most_recent_gnt;
integer onehot_aw_gnt[NB_MASTER];

logic [NB_MASTER-1:0][NB_SLAVE-1:0] w_pending_reqs;
logic [NB_MASTER-1:0][NB_SLAVE-1:0] w_most_recent_gnt;
integer onehot_w_gnt[NB_MASTER];


logic [NB_SLAVE-1:0][NB_MASTER-1:0] r_pending_reqs;
logic [NB_SLAVE-1:0][NB_MASTER-1:0] r_most_recent_gnt;
integer onehot_r_gnt[NB_SLAVE];

logic [NB_SLAVE-1:0][NB_MASTER-1:0] b_pending_reqs;
logic [NB_SLAVE-1:0][NB_MASTER-1:0] b_most_recent_gnt;
integer onehot_b_gnt[NB_SLAVE];

logic [NB_SLAVE-1:0] slave_port_serv;
logic [NB_MASTER-1:0] master_port_serv;
/*
sequence addr_check(addr, master_port_id);
   addr < end_addr[k] && addr >= start_addr[k];
endsequence
*/
function [NB_SLAVE-1:0] find_next_slave; // function definition starts here
	input [NB_SLAVE-1:0] pending_reqs;
	input [NB_SLAVE-1:0] most_recent_gnt;
	//find_next_slave = pending_reqs | most_recent_gnt;
	integer k;
	logic temp = 0;
	begin
	if (!|pending_reqs) begin
		find_next_slave = most_recent_gnt;
	end
	else begin
		for (k=0; k < NB_SLAVE; k = k +1) begin
			find_next_slave[k] = pending_reqs[k] & temp;
			temp = temp ^ find_next_slave[k];
			temp = most_recent_gnt[k] | temp;
		end
		if(temp) begin
		for (k=0; k < NB_SLAVE; k=k+1) begin
			find_next_slave[k] = pending_reqs[k] & temp;
			temp = temp ^ find_next_slave[k];
		end
		end
	end
	end
endfunction

function [NB_MASTER-1:0] find_next_master; // function definition starts here
	input [NB_MASTER-1:0] pending_reqs;
	input [NB_MASTER-1:0] most_recent_gnt;
	integer k;
	logic [NB_MASTER-1:0 ]temp = 0;
	begin
	for (k=0; k < NB_MASTER; k = k +1) begin
		temp = most_recent_gnt[k] | temp;
		find_next_master[k] = pending_reqs[k] && temp;
		if (find_next_master[k]) begin
			return;
		end
	end
	for (k=0; k < NB_MASTER; k=k+1) begin
		find_next_master[k] = pending_reqs[k] && temp;
		if (find_next_master[k]) begin
			return;
		end
	end
	end
endfunction

generate
	genvar i,k;
	for (k=0; k<NB_MASTER; k++) begin
		for (i=0; i<NB_SLAVE; i++) begin
/*			assign ar_pending_reqs[k][i] = ((s_slave_ar_valid[i]) && s_slave_ar_addr[i] <= end_addr[k] && s_slave_ar_addr[i] >= start_addr[k]);	*/
			
		end
	end
endgenerate

logic [NB_SLAVE-1:0][AXI_ADDR_WIDTH-1:0]    prev_slave_ar_addr;
logic [NB_SLAVE-1:0]			    prev_slave_ar_valid;
logic [NB_SLAVE-1:0][AXI_ADDR_WIDTH-1:0]    prev_slave_aw_addr;
logic [NB_SLAVE-1:0]			    prev_slave_aw_valid;

always @(posedge clk) begin
	integer i;	
	for(i=0; i<NB_SLAVE; i=i+1) begin
		prev_slave_ar_addr[i] <= s_slave_ar_addr[i];	
		prev_slave_ar_valid[i] <= s_slave_ar_valid[i];
		prev_slave_aw_addr[i] <= s_slave_aw_addr[i];	
		prev_slave_aw_valid[i] <= s_slave_aw_valid[i];
	end
end


always @(posedge clk) begin
	integer k;
	integer i;
	if(!rst_n) begin
		for (k=0; k<NB_MASTER; k++) begin
			for (i=0; i<NB_SLAVE; i++) begin
				aw_pending_reqs[k][i] = 0;
				w_pending_reqs[k][i] = 0;
				ar_pending_reqs[k][i] = 0;
				aw_most_recent_gnt[k][i] = 0;
				w_most_recent_gnt[k][i] = 0;
				ar_most_recent_gnt[k][i] = 0;
			end
			aw_most_recent_gnt[k][NB_SLAVE-1] = 1;
			w_most_recent_gnt[k][NB_SLAVE-1] = 1;
			ar_most_recent_gnt[k][NB_SLAVE-1] = 1;		
			onehot_aw_gnt[k] = NB_SLAVE-1;
			onehot_w_gnt[k] = NB_SLAVE-1;
			onehot_ar_gnt[k] = NB_SLAVE-1;	
		end	
	end
	else begin
	for (k=0; k<NB_MASTER; k++) begin
		for (i=0; i<NB_SLAVE; i++) begin
			if ((s_slave_aw_valid[i]) && s_slave_aw_addr[i] <= end_addr[k] && s_slave_aw_addr[i] >= start_addr[k]) begin
				aw_pending_reqs[k][i] = 1;
			end
			if ((s_slave_w_valid[i]) && s_slave_aw_addr[i] <= end_addr[k] && s_slave_aw_addr[i] >= start_addr[k]) begin
				w_pending_reqs[k][i] = 1;
			end
			if ((s_slave_ar_valid[i]) && s_slave_ar_addr[i] <= end_addr[k] && s_slave_ar_addr[i] >= start_addr[k]) begin
				ar_pending_reqs[k][i] = 1;
			end
			/*ar_pending_reqs[k][i] = ((s_slave_ar_valid[i]) && s_slave_ar_addr[i] < end_addr[k] && s_slave_ar_addr[i] >= start_addr[k]);*/
		end
	
		if (s_master_aw_ready[k]) begin
			//find x (i.e. next slave port which will be serviced)
			if (|(aw_pending_reqs[k])) begin
				aw_most_recent_gnt[k] = find_next_slave(aw_pending_reqs[k], aw_most_recent_gnt[k]);
				aw_pending_reqs[k] = aw_pending_reqs[k] ^ aw_most_recent_gnt[k];
				onehot_aw_gnt[k] = onehot_s_to_bin(aw_most_recent_gnt[k]);
			end
		end
		if (s_master_w_ready[k]) begin
			//find x (i.e. next slave port which will be serviced)
			if (|(w_pending_reqs[k])) begin
				w_most_recent_gnt[k] = find_next_slave(w_pending_reqs[k], w_most_recent_gnt[k]);
				w_pending_reqs[k] = w_pending_reqs[k] ^ w_most_recent_gnt[k];
				onehot_w_gnt[k] = onehot_s_to_bin(w_most_recent_gnt[k]);
			end
		end
		if (s_master_ar_ready[k]) begin
			//find x (i.e. next slave port which will be serviced)
			if (|(ar_pending_reqs[k])) begin
				ar_most_recent_gnt[k] = find_next_slave(ar_pending_reqs[k], ar_most_recent_gnt[k]);
				ar_pending_reqs[k] = ar_pending_reqs[k] ^ ar_most_recent_gnt[k];
				onehot_ar_gnt[k] = onehot_s_to_bin(ar_most_recent_gnt[k]);
			end
		end				
	end
	end
end

function integer onehot_m_to_bin;	
	input [NB_MASTER-1:0] invec;
	integer i;
	onehot_m_to_bin = 0;
	for(i=0; i<NB_MASTER; i++) begin
		if (invec[i] == 1'b1) onehot_m_to_bin = i;	
	end
endfunction

function integer onehot_s_to_bin;	
	input [NB_SLAVE-1:0] invec;
	integer i;
	onehot_s_to_bin = 0;
	for(i=0; i<NB_SLAVE; i++) begin
		if (invec[i] == 1'b1) onehot_s_to_bin = i;
	end
endfunction

generate
	genvar k;
	for(k=0; k<NB_MASTER; k=k+1) begin
		RR_prop_aw: assert property (@(posedge clk) disable iff (!rst_n)
			$past(master[k].aw_ready) && $past(master[k].aw_valid) |-> 
				($past(master[k].aw_addr) == prev_slave_aw_addr[onehot_aw_gnt[k]]) && prev_slave_aw_valid[onehot_aw_gnt[k]]);

		RR_prop_ar: assert property (@(posedge clk) disable iff (!rst_n)
			$past(master[k].ar_ready) && $past(master[k].ar_valid) |-> 
				($past(master[k].ar_addr) == prev_slave_ar_addr[onehot_ar_gnt[k]]) && prev_slave_ar_valid[onehot_ar_gnt[k]]);

	end
/*
	for(k=0; k<NB_SLAVE; k=k+1) begin
		assert property (@(posedge clk) disable iff (rst_n)
			if req_gnt_signal |-> req_gnt_signal = (pending_req that comes after most_recent_gnt));
	end*/
endgenerate
/*
sequence id_check();

endsequence
	
always @(posedge clk) begin
	localparam k, i;
	for (k=0; k<NB_SLAVE; k++) begin
		for (i=0; i<NB_MASTER; i++) begin
			if ($rose(master[i].r_valid) && id_check(master[i].b_id, k)) begin
				r_pending_reqs[i][k] = 1;
			end
			if ($rose(master[i].b_valid) && id_check(master[i].r_id, k)) begin
				w_pending_reqs[i][k] = 1;
			end

		end

		if (slave[k].b_ready) begin
			//find x (i.e. next slave port which will be serviced)
			if (b_pending_reqs[k]) begin
				master_port_serv = find_next_master(b_pending_reqs[k], b_most_recent_gnt[k]);
				b_pending_reqs[k] = b_pending_reqs[k] ^ master_port_serv;
				b_most_recent_gnt[k] = master_port_serv;
			end
		end
		if (slave[k].r_ready) begin
			//find x (i.e. next slave port which will be serviced)
			if (r_pending_reqs[k]) begin
				master_port_serv = find_next_master(r_pending_reqs[k], r_most_recent_gnt[k]);
				r_pending_reqs[k] = r_pending_reqs[k] ^ master_port_serv;
				r_most_recent_gnt[k] = master_port_serv;
			end
		end

	end
end*/


endmodule
