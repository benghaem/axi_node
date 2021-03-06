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
      assign                        master[i].aw_valid                     = s_master_aw_valid[i]; //& rst_n; //fix bad reset behavior
      assign s_master_aw_ready[i] = master[i].aw_ready & rst_n;

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
      assign                        master[i].ar_valid                     = s_master_ar_valid[i]; //& rst_n; //fix bad reset behavior
      assign s_master_ar_ready[i] = master[i].ar_ready & rst_n;

      assign                        master[i].w_data  = s_master_w_data[i];
      assign                        master[i].w_strb  = s_master_w_strb[i];
      assign                        master[i].w_last  = s_master_w_last[i];
      assign                        master[i].w_user  = s_master_w_user[i];
      assign                        master[i].w_valid = s_master_w_valid[i];
      assign s_master_w_ready[i]  = master[i].w_ready & rst_n;

      assign s_master_b_id[i]     = master[i].b_id[AXI_ID_WIDTH_INIT-1:0];
      assign s_master_b_resp[i]   = master[i].b_resp;
      assign s_master_b_valid[i]  = master[i].b_valid & rst_n;
      assign s_master_b_user[i]   = master[i].b_user;
      assign                        master[i].b_ready = s_master_b_ready[i];

      assign s_master_r_id[i]     = master[i].r_id[AXI_ID_WIDTH_INIT-1:0];
      assign s_master_r_data[i]   = master[i].r_data;
      assign s_master_r_resp[i]   = master[i].r_resp;
      assign s_master_r_last[i]   = master[i].r_last;
      assign s_master_r_user[i]   = master[i].r_user;
      assign s_master_r_valid[i]  = master[i].r_valid & rst_n;
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

//Maximum Burst length
localparam MX_BURST = 2;

//
//  __  __ __  __   _   ___     _   ___ ___ _   _ __  __ ___
// |  \/  |  \/  | /_\ | _ \   /_\ / __/ __| | | |  \/  | __|
// | |\/| | |\/| |/ _ \|  _/  / _ \\__ \__ \ |_| | |\/| | _|
// |_|  |_|_|  |_/_/ \_\_|   /_/ \_\___/___/\___/|_|  |_|___|
//
//

//Addressing setup
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

//All addresses are valid, have correct ids, and only select region 0
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
        reset_b_val: assume property(@(posedge clk)
            $rose(rst_n) |-> !master[k].b_valid);
        reset_r_val: assume property(@(posedge clk)
            $rose(rst_n) |-> !master[k].r_valid);

        correct_ar_ready_start: assume property(@(posedge clk) disable iff(!rst_n)
            $rose(rst_n) |-> ##[1:SL_RT-1] $rose(master[k].ar_ready));
        correct_aw_ready_start: assume property(@(posedge clk) disable iff(!rst_n)
            $rose(rst_n) |-> ##[1:SL_RT-1] $rose(master[k].aw_ready));

        functional_slave_ar: assume property(@(posedge clk) disable iff(!rst_n)
            $fell(master[k].ar_ready) |-> ##[1:SL_RT-1] $rose(master[k].ar_ready));
        functional_slave_aw: assume property(@(posedge clk) disable iff(!rst_n)
            $fell(master[k].aw_ready) |-> ##[1:SL_RT-1] $rose(master[k].aw_ready));

        handshake_s_b_0: assume property(@(posedge clk) disable iff(!rst_n)
            master[k].b_valid && !master[k].b_ready |=> master[k].b_valid);

        handshake_s_r_0: assume property(@(posedge clk) disable iff(!rst_n)
            master[k].r_valid && !master[k].r_ready |=> master[k].r_valid);

        handshake_s_b_v: assume property(@(posedge clk) disable iff(!rst_n)
            master[k].b_ready && master[k].b_valid |=> $fell(master[k].b_valid));
        handshake_s_r_v: assume property(@(posedge clk) disable iff(!rst_n)
            master[k].r_valid && master[k].r_ready |=> $fell(master[k].r_valid));

        const_s_b_id: assume property(a_imp_stable(master[k].b_valid, master[k].b_id));
        const_s_r_id: assume property(a_imp_stable(master[k].r_valid, master[k].r_id));

       
    end
endgenerate

generate
    genvar j;
    for (j = 0; j < NB_SLAVE; j++)
    begin
        
        reset_ar_val: assume property(@(posedge clk)
            $rose(rst_n) |-> !slave[j].ar_valid);
        reset_aw_val: assume property(@(posedge clk)
            $rose(rst_n) |-> !slave[j].aw_valid);

        //always on  master bw_channel
        correct_r_ready_start: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].r_ready == 1);
        correct_b_ready_start: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].b_ready == 1);


        // Valid should remain high until the cycle after ready is asserted
        handshake_m_ar_0: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].ar_valid && !slave[j].ar_ready |=> slave[j].ar_valid);
        handshake_m_aw_0: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].aw_valid && !slave[j].aw_ready |=> slave[j].aw_valid);
        
        handshake_m_w_0: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].w_valid && !slave[j].w_ready |=> slave[j].w_valid);


        // Valid should fall after seeing a ready
        handshake_m_ar_v: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].ar_ready && slave[j].ar_valid |=> $fell(slave[j].ar_valid));
        handshake_m_aw_1: assume property(@(posedge clk) disable iff(!rst_n)
            slave[j].aw_valid && slave[j].aw_ready |=> $fell(slave[j].aw_valid));

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

//Keep a log of outstanding writes

logic [NB_SLAVE-1:0] outstanding_write;

always @(posedge clk) begin
    integer i;
    for (i = 0; i < NB_SLAVE; i++)  begin
        if (!rst_n) begin
            outstanding_write[i] = 0;
        end
        else begin
            if (!s_slave_w_last[i]) begin
                outstanding_write[i] = s_slave_aw_valid[i] | outstanding_write[i];
            end
            else begin
                outstanding_write[i] = 0;
            end
        end
    end

end

generate
    genvar j;
    for (j = 0; j < NB_SLAVE; j++)
    begin

    assume property(@(posedge clk) disable iff(!rst_n)
        outstanding_write[j] && !slave[j].aw_valid |=> !slave[j].aw_valid);

    assume property(@(posedge clk) disable iff (!rst_n)
        slave[j].aw_valid |-> ##[0:SL_RT] slave[j].w_valid);

    assume property(@(posedge clk) disable iff (!rst_n)
        slave[j].w_valid |-> ##[0:MX_BURST] (slave[j].w_last && slave[j].w_valid) ##1 (!slave[j].w_valid));

    assume property(@(posedge clk) disable iff (!rst_n)
        !slave[j].w_valid |-> !slave[j].w_last);

    assume property(@(posedge clk) disable iff (!rst_n)
        slave[j].w_last |=> !slave[j].w_valid);

    assume property(@(posedge clk) disable iff(!rst_n)
        slave[j].w_last |=> $rose(slave[j].b_valid));

    assume property(@(posedge clk) disable iff(!rst_n)
        slave[j].w_valid |-> !slave[j].b_valid);
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
    genvar j, k, q;

    for (k = 0; k < NB_SLAVE; k++)
    begin
        for (q = 0; q < NB_SLAVE; q++)
        begin
            //Hacky safety that only works for our given mmap
            if ((k != q)) begin
                safe_ar: assert property(@(posedge clk) disable iff (!rst_n)
                (slave[k].ar_addr >> 12) == (slave[q].ar_addr >> 12) |-> !(slave[k].ar_ready && slave[q].ar_ready));

                safe_aw: assert property(@(posedge clk) disable iff (!rst_n)
                (slave[k].aw_addr >> 12) == (slave[q].aw_addr >> 12) |-> !(slave[k].aw_ready && slave[q].aw_ready));
            end
        end
    end
endgenerate



//Liveness w/o ordering
generate
    genvar j, k;

    for (k = 0; k < NB_MASTER; k++)
    begin
        for (j = 0; j < NB_SLAVE; j++)
        begin


            valid_master_iface_ar: assert property(@(posedge clk) disable iff(!rst_n)
            slave[j].ar_valid && slave[j].ar_addr < end_addr[k] && slave[j].ar_addr >= start_addr[k] |->
                 ##[0:SL_RT * NB_SLAVE] (master[k].ar_valid && slave[j].ar_valid && slave[j].ar_ready && master[k].ar_ready && (master[k].ar_addr == slave[j].ar_addr) ) );

            valid_master_iface_aw: assert property(@(posedge clk) disable iff(!rst_n)
            slave[j].aw_valid && slave[j].aw_addr < end_addr[k] && slave[j].aw_addr >= start_addr[k] |->
                 ##[0:SL_RT * 2 *  NB_SLAVE] (master[k].aw_valid && slave[j].aw_valid && slave[j].aw_ready && master[k].aw_ready && (master[k].aw_addr == slave[j].aw_addr) ) );

            valid_master_iface_w: assert property(@(posedge clk) disable iff(!rst_n)
            slave[j].aw_valid && slave[j].aw_addr < end_addr[k] && slave[j].aw_addr >= start_addr[k] |->
                 ##[0:(SL_RT * 2 * NB_SLAVE)] (master[k].w_valid && slave[j].w_valid && slave[j].w_ready && master[k].w_ready && (master[k].w_data == slave[j].w_data)) );

            valid_slave_iface_b: assert property(@(posedge clk) disable iff(!rst_n)
            master[k].b_valid && (master[k].b_id[AXI_ID_WIDTH_INIT-1:AXI_ID_WIDTH] == j) |->
                 ##[0:SL_RT * NB_MASTER] (slave[j].b_valid && master[k].b_valid && master[k].b_ready && slave[j].b_ready
                 && (slave[j].b_id[AXI_ID_WIDTH-1:0] == master[k].b_id[AXI_ID_WIDTH-1:0]) ) );

            valid_slave_iface_r: assert property(@(posedge clk) disable iff(!rst_n)
                    master[k].r_valid && (master[k].r_id[AXI_ID_WIDTH_INIT-1:AXI_ID_WIDTH] == j) |->
                    ##[0:SL_RT * NB_MASTER] (slave[j].r_valid && master[k].r_valid && master[k].r_ready && slave[j].r_ready && 
                    (slave[j].r_id[AXI_ID_WIDTH-1:0] == master[k].r_id[AXI_ID_WIDTH-1:0]) ) );

       end
    end
endgenerate

//RR assertions
//at every master node on the interface, we will keep track of the requests it has from the slave nodes in a bitmap manner.
//for example at master node 1, if there are outstanding requests from slave ports 2 and 3, then pending_reqs[1][2] and pending_reqs[1][3] = 1.
//most_recent_gnt[0] will be a onehot vector indicating which slave port had the last access to the master.
//Need this for every channel -> Yes

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

function [NB_MASTER-1:0][NB_SLAVE-1:0] gen_pending; // function definition starts here
    input [NB_SLAVE-1:0] gp_aw_valid;
    input [NB_SLAVE-1:0][AXI_ADDR_WIDTH-1:0] gp_aw_addr;
    integer k, i;
    begin
        for (k=0; k<NB_MASTER; k++) begin
            for (i=0; i<NB_SLAVE; i++) begin

                if ((gp_aw_valid[i]) && gp_aw_addr[i] <= end_addr[k] && gp_aw_addr[i] >= start_addr[k]) begin
                    gen_pending[k][i] = 1;
                end
                else begin
                    gen_pending[k][i] = 0;
                end

            end
        end
    end
endfunction

function [NB_MASTER-1:0][NB_SLAVE-1:0] gen_new_grant; // function definition starts here
    input [NB_MASTER-1:0][NB_SLAVE-1:0] gmr_curr_grant;
    input [NB_MASTER-1:0][NB_SLAVE-1:0] gmr_pending;
    input [NB_MASTER-1:0] gmr_ready;
    integer k;
    begin
        for (k=0; k<NB_MASTER; k++) begin
            if (gmr_ready[k]) begin
                //find x (i.e. next slave port which will be serviced)
                if (|(gmr_pending[k])) begin
                    gen_new_grant[k] = find_next_slave(gmr_pending[k], gmr_curr_grant[k]);
                end 
                else begin
                    gen_new_grant[k] = gmr_curr_grant[k];
                end
            end
            else begin
                    gen_new_grant[k] = gmr_curr_grant[k];
            end
        end
    end
endfunction

typedef integer onehot_arr[NB_MASTER];

function [NB_MASTER-1:0][NB_SLAVE-1:0] gen_final_pending; // function definition starts here
    input [NB_MASTER-1:0][NB_SLAVE-1:0] gfp_new_grant;
    input [NB_MASTER-1:0][NB_SLAVE-1:0] gfp_pending;
    integer k;
    begin
        for (k=0; k<NB_MASTER; k++) begin
            if(s_master_aw_ready[k]) begin
                gen_final_pending[k] = gfp_pending[k] ^ gfp_new_grant[k];
            end
        end
    end
endfunction


function onehot_arr gen_onehot; // function definition starts here
    input [NB_MASTER-1:0][NB_SLAVE-1:0] go_new_grant;
    integer k;
    begin
        for (k=0; k<NB_MASTER; k++) begin
            gen_onehot[k] = onehot_s_to_bin(go_new_grant[k]);
        end
    end
endfunction

localparam MD_AR = 0;
localparam MD_AW = 1;
localparam MD_W = 2;

logic [2:0][NB_MASTER-1:0][NB_SLAVE-1:0] last_pending;
logic [2:0][NB_MASTER-1:0][NB_SLAVE-1:0] inter_pending;
logic [2:0][NB_MASTER-1:0][NB_SLAVE-1:0] final_pending;

logic [2:0][NB_MASTER-1:0][NB_SLAVE-1:0] last_grant;
logic [2:0][NB_MASTER-1:0][NB_SLAVE-1:0] new_grant;
integer cmb_onehot_aw_gnt[NB_MASTER];
integer cmb_onehot_w_gnt[NB_MASTER];
integer cmb_onehot_ar_gnt[NB_MASTER];

assign inter_pending[MD_AW] = gen_pending(s_slave_aw_valid, s_slave_aw_addr);
assign new_grant[MD_AW] = gen_new_grant(last_grant[MD_AW], inter_pending[MD_AW], s_master_aw_ready);
//assign final_pending[MD_AW] = gen_final_pending(new_grant[MD_AW], inter_pending[MD_AW]);

assign inter_pending[MD_AR] = gen_pending(s_slave_ar_valid, s_slave_ar_addr);
assign new_grant[MD_AR] = gen_new_grant(last_grant[MD_AR], inter_pending[MD_AR], s_master_ar_ready);
//assign final_pending[MD_AR] = gen_final_pending(new_grant[MD_AR], inter_pending[MD_AR]);

assign inter_pending[MD_W] = gen_pending(s_slave_w_valid, s_slave_aw_addr);
assign new_grant[MD_W] = gen_new_grant(last_grant[MD_W], inter_pending[MD_W], s_master_w_ready);
//assign final_pending[MD_W] = gen_final_pending(new_grant[MD_W], inter_pending[MD_W]);

assign cmb_onehot_aw_gnt = gen_onehot(new_grant[MD_AW]);
assign cmb_onehot_ar_gnt = gen_onehot(new_grant[MD_AR]);
assign cmb_onehot_w_gnt = gen_onehot(new_grant[MD_W]);

always @(posedge clk) begin
    integer i, k, md;
    if (!rst_n) begin
        for (md = 0; md < 3; md++) begin
            for (k=0; k<NB_MASTER; k++) begin
                for (i=0; i<NB_SLAVE; i++) begin
                    last_pending[md][k][i] = 0;
                    last_grant[md][k][i] = 0;
                end
                last_grant[md][k][NB_SLAVE-1] = 1;
            end
        end
    end
    else begin
        //last_pending = final_pending;
        last_grant = new_grant;
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


//Round robin assertions
generate
    genvar k;
    for(k=0; k<NB_MASTER; k=k+1) begin
        RR_prop_aw: assert property (@(posedge clk) disable iff (!rst_n)
            (s_master_aw_valid[k]) && (s_master_aw_ready[k]) |-> 
                (master[k].aw_addr == s_slave_aw_addr[cmb_onehot_aw_gnt[k]]) && s_slave_aw_valid[cmb_onehot_aw_gnt[k]]);

        RR_prop_aw_id: assert property (@(posedge clk) disable iff (!rst_n)
            (s_master_aw_valid[k]) && (s_master_aw_ready[k]) |-> 
                master[k].aw_id == {cmb_onehot_aw_gnt[k][AXI_ID_WIDTH_INIT-AXI_ID_WIDTH-1:0],s_slave_aw_id[cmb_onehot_aw_gnt[k]][AXI_ID_WIDTH-1:0]});

        RR_prop_ar: assert property (@(posedge clk) disable iff (!rst_n)
            master[k].ar_ready && master[k].ar_valid |-> 
                (master[k].ar_addr == s_slave_ar_addr[cmb_onehot_ar_gnt[k]]) && s_slave_ar_valid[cmb_onehot_ar_gnt[k]]);

        RR_prop_ar_id: assert property (@(posedge clk) disable iff (!rst_n)
            (s_master_ar_valid[k]) && (s_master_ar_ready[k]) |-> 
                master[k].ar_id == {cmb_onehot_ar_gnt[k][AXI_ID_WIDTH_INIT-AXI_ID_WIDTH-1:0],s_slave_ar_id[cmb_onehot_ar_gnt[k]][AXI_ID_WIDTH-1:0]});


    end

endgenerate

endmodule
