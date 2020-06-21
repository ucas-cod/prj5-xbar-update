/* =========================================
* Top module of custom CPU with 
* 1). a fixed design that contains 
* a number of AXI ICs, and 
* 2). clock wizard that generates 
* CPU source clock. 
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 29/02/2020
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module cpu_test_top (
  input sys_clk,
  input sys_reset_n
);

  wire cpu_clk;
  wire cpu_reset_n;

  wire [31:0]cpu_inst_araddr;
  wire [1:0]cpu_inst_arburst;
  wire [3:0]cpu_inst_arcache;
  wire [7:0]cpu_inst_arlen;
  wire [0:0]cpu_inst_arlock;
  wire [2:0]cpu_inst_arprot;
  wire [3:0]cpu_inst_arqos;
  wire cpu_inst_arready;
  wire [2:0]cpu_inst_arsize;
  wire cpu_inst_arvalid;
  wire [31:0]cpu_inst_rdata;
  wire cpu_inst_rlast;
  wire cpu_inst_rready;
  wire [1:0]cpu_inst_rresp;
  wire cpu_inst_rvalid;
  wire [31:0]cpu_mem_araddr;
  wire [1:0]cpu_mem_arburst;
  wire [3:0]cpu_mem_arcache;
  wire [7:0]cpu_mem_arlen;
  wire [0:0]cpu_mem_arlock;
  wire [2:0]cpu_mem_arprot;
  wire [3:0]cpu_mem_arqos;
  wire [0:0]cpu_mem_arready;
  wire [2:0]cpu_mem_arsize;
  wire [0:0]cpu_mem_arvalid;
  wire [31:0]cpu_mem_awaddr;
  wire [1:0]cpu_mem_awburst;
  wire [3:0]cpu_mem_awcache;
  wire [7:0]cpu_mem_awlen;
  wire [0:0]cpu_mem_awlock;
  wire [2:0]cpu_mem_awprot;
  wire [3:0]cpu_mem_awqos;
  wire [0:0]cpu_mem_awready;
  wire [2:0]cpu_mem_awsize;
  wire [0:0]cpu_mem_awvalid;
  wire [0:0]cpu_mem_bready;
  wire [1:0]cpu_mem_bresp;
  wire [0:0]cpu_mem_bvalid;
  wire [31:0]cpu_mem_rdata;
  wire [0:0]cpu_mem_rlast;
  wire [0:0]cpu_mem_rready;
  wire [1:0]cpu_mem_rresp;
  wire [0:0]cpu_mem_rvalid;
  wire [31:0]cpu_mem_wdata;
  wire [0:0]cpu_mem_wlast;
  wire [0:0]cpu_mem_wready;
  wire [3:0]cpu_mem_wstrb;
  wire [0:0]cpu_mem_wvalid;
  wire [31:0]cpu_perf_cnt_araddr;
  wire [2:0]cpu_perf_cnt_arprot;
  wire [0:0]cpu_perf_cnt_arready;
  wire [0:0]cpu_perf_cnt_arvalid;
  wire [31:0]cpu_perf_cnt_awaddr;
  wire [2:0]cpu_perf_cnt_awprot;
  wire [0:0]cpu_perf_cnt_awready;
  wire [0:0]cpu_perf_cnt_awvalid;
  wire [0:0]cpu_perf_cnt_bready;
  wire [1:0]cpu_perf_cnt_bresp;
  wire [0:0]cpu_perf_cnt_bvalid;
  wire [31:0]cpu_perf_cnt_rdata;
  wire [0:0]cpu_perf_cnt_rready;
  wire [1:0]cpu_perf_cnt_rresp;
  wire [0:0]cpu_perf_cnt_rvalid;
  wire [31:0]cpu_perf_cnt_wdata;
  wire [0:0]cpu_perf_cnt_wready;
  wire [3:0]cpu_perf_cnt_wstrb;
  wire [0:0]cpu_perf_cnt_wvalid;
  wire [31:0]	cpu_perf_cnt_0;
  wire [31:0]	cpu_perf_cnt_1;
  wire [31:0]	cpu_perf_cnt_2;
  wire [31:0]	cpu_perf_cnt_3;
  wire [31:0]	cpu_perf_cnt_4;
  wire [31:0]	cpu_perf_cnt_5;
  wire [31:0]	cpu_perf_cnt_6;
  wire [31:0]	cpu_perf_cnt_7;
  wire [31:0]	cpu_perf_cnt_8;
  wire [31:0]	cpu_perf_cnt_9;
  wire [31:0]	cpu_perf_cnt_10;
  wire [31:0]	cpu_perf_cnt_11;
  wire [31:0]	cpu_perf_cnt_12;
  wire [31:0]	cpu_perf_cnt_13;
  wire [31:0]	cpu_perf_cnt_14;
  wire [31:0]	cpu_perf_cnt_15;

  wire [31:0]	axi_hp0_araddr;
  wire [1:0]	axi_hp0_arburst;
  wire [3:0]	axi_hp0_arcache;
  wire [7:0]	axi_hp0_arlen;
  wire [0:0]	axi_hp0_arlock;
  wire [2:0]	axi_hp0_arprot;
  wire [3:0]	axi_hp0_arqos;
  wire			  axi_hp0_arready;
  wire [3:0]	axi_hp0_arregion;
  wire [2:0]	axi_hp0_arsize;
  wire		    axi_hp0_arvalid;
  wire [5:0]  axi_hp0_arid;
  wire [31:0]	axi_hp0_awaddr;
  wire [1:0]	axi_hp0_awburst;
  wire [3:0]	axi_hp0_awcache;
  wire [7:0]	axi_hp0_awlen;
  wire [0:0]	axi_hp0_awlock;
  wire [2:0]	axi_hp0_awprot;
  wire [3:0]	axi_hp0_awqos;
  wire			  axi_hp0_awready;
  wire [3:0]	axi_hp0_awregion;
  wire [2:0]	axi_hp0_awsize;
  wire		    axi_hp0_awvalid;
  wire [5:0]  axi_hp0_awid;
  wire        axi_hp0_bready;
  wire [1:0]  axi_hp0_bresp;
  wire        axi_hp0_bvalid;
  wire [5:0]  axi_hp0_bid;
  wire [31:0] axi_hp0_rdata;
  wire        axi_hp0_rlast;
  wire        axi_hp0_rready;
  wire [1:0]  axi_hp0_rresp;
  wire [5:0]  axi_hp0_rid;
  wire        axi_hp0_rvalid;
  wire [31:0] axi_hp0_wdata;
  wire        axi_hp0_wlast;
  wire        axi_hp0_wready;
  wire [3:0]  axi_hp0_wstrb;
  wire        axi_hp0_wvalid;
  wire [5:0]  axi_hp0_wid;

  cpu_sim_wrapper		u_cpu_sim	(
    .sys_clk	(sys_clk),
	.system_clk	(cpu_clk),

    .sys_reset_n	(sys_reset_n),
    .cpu_reset_n	(cpu_reset_n),

    .axi_hp0_araddr   (axi_hp0_araddr + 32'h40000000  ),      //49
    .axi_hp0_arburst  (axi_hp0_arburst ),
    //.axi_hp0_arcache  (axi_hp0_arcache ),
    .axi_hp0_arlen    (axi_hp0_arlen   ),
    //.axi_hp0_arlock   (axi_hp0_arlock  ),
    //.axi_hp0_arprot   (axi_hp0_arprot  ),
    //.axi_hp0_arqos    (axi_hp0_arqos   ),
    .axi_hp0_arready  (axi_hp0_arready ),
    .axi_hp0_arsize   (axi_hp0_arsize  ),
    .axi_hp0_arvalid  (axi_hp0_arvalid ),
    .axi_hp0_arid     (axi_hp0_arid),
    .axi_hp0_awaddr   (axi_hp0_awaddr + 32'h40000000  ),
    .axi_hp0_awburst  (axi_hp0_awburst ),
    //.axi_hp0_awcache  (axi_hp0_awcache ),
    .axi_hp0_awlen   (axi_hp0_awlen   ),
    //.axi_hp0_awlock  (axi_hp0_awlock  ),
    //.axi_hp0_awprot  (axi_hp0_awprot  ),
    //.axi_hp0_awqos   (axi_hp0_awqos   ),
    .axi_hp0_awready (axi_hp0_awready ),
    .axi_hp0_awsize  (axi_hp0_awsize  ),
    .axi_hp0_awvalid (axi_hp0_awvalid ),
    .axi_hp0_awid   (axi_hp0_awid),
    .axi_hp0_bready (axi_hp0_bready ),
    .axi_hp0_bresp  (axi_hp0_bresp  ),
    .axi_hp0_bvalid (axi_hp0_bvalid ),
    .axi_hp0_bid    (axi_hp0_bid),
    .axi_hp0_rdata  (axi_hp0_rdata  ),         //64
    .axi_hp0_rlast  (axi_hp0_rlast  ),
    .axi_hp0_rready (axi_hp0_rready ),
    .axi_hp0_rresp  (axi_hp0_rresp  ),
    .axi_hp0_rvalid (axi_hp0_rvalid ),
    .axi_hp0_rid     (axi_hp0_rid),
    .axi_hp0_wdata  (axi_hp0_wdata  ),
    .axi_hp0_wlast  (axi_hp0_wlast  ),
    .axi_hp0_wready (axi_hp0_wready ),
    .axi_hp0_wstrb  (axi_hp0_wstrb  ),
    .axi_hp0_wvalid (axi_hp0_wvalid )
  );

AXI4Xbar  u_AXI4Xbar(
    .clock    (cpu_clk),
    .reset    (~cpu_reset_n),
    .io_in_0_aw_ready       (cpu_mem_awready),
    .io_in_0_aw_valid       (cpu_mem_awvalid),
    .io_in_0_aw_bits_addr   (cpu_mem_awaddr),
    .io_in_0_aw_bits_prot   ('d0),
    .io_in_0_aw_bits_id     ('d0),
    //.io_in_0_aw_bits_user,
    .io_in_0_aw_bits_len    (cpu_mem_awlen),
    .io_in_0_aw_bits_size   (cpu_mem_awsize),
    .io_in_0_aw_bits_burst  (cpu_mem_awburst),
    .io_in_0_aw_bits_lock   ('d0),
    .io_in_0_aw_bits_cache  ('d0),
    .io_in_0_aw_bits_qos    ('d0),
    .io_in_0_w_ready        (cpu_mem_wready),
    .io_in_0_w_valid        (cpu_mem_wvalid),
    .io_in_0_w_bits_data    (cpu_mem_wdata),
    .io_in_0_w_bits_strb    (cpu_mem_wstrb),
    .io_in_0_w_bits_last    (cpu_mem_wlast),
    .io_in_0_b_ready        (cpu_mem_bready),
    .io_in_0_b_valid        (cpu_mem_bvalid),
    .io_in_0_b_bits_resp    (cpu_mem_bresp),
    //.io_in_0_b_bits_id,
    //.io_in_0_b_bits_user,
    .io_in_0_ar_ready       (cpu_mem_arready),
    .io_in_0_ar_valid       (cpu_mem_arvalid),
    .io_in_0_ar_bits_addr   (cpu_mem_araddr),
    .io_in_0_ar_bits_prot   ('d0),
    .io_in_0_ar_bits_id     ('d0),
    //.io_in_0_ar_bits_user,
    .io_in_0_ar_bits_len    (cpu_mem_arlen),
    .io_in_0_ar_bits_size   (cpu_mem_arsize),
    .io_in_0_ar_bits_burst  (cpu_mem_arburst),
    .io_in_0_ar_bits_lock   ('d0),
    .io_in_0_ar_bits_cache  ('d0),
    .io_in_0_ar_bits_qos    ('d0),
    .io_in_0_r_ready        (cpu_mem_rready),
    .io_in_0_r_valid        (cpu_mem_rvalid),
    .io_in_0_r_bits_resp    (cpu_mem_rresp),
    .io_in_0_r_bits_data    (cpu_mem_rdata),
    .io_in_0_r_bits_last    (cpu_mem_rlast),
    //.io_in_0_r_bits_id,
    //.io_in_0_r_bits_user,
    //.io_in_1_aw_ready,
    .io_in_1_aw_valid       ('d0),
    //.io_in_1_aw_bits_addr,
    //.io_in_1_aw_bits_prot,
    //.io_in_1_aw_bits_id,
    //.io_in_1_aw_bits_user,
    //.io_in_1_aw_bits_len,
    //.io_in_1_aw_bits_size,
    //.io_in_1_aw_bits_burst,
    //.io_in_1_aw_bits_lock,
    //.io_in_1_aw_bits_cache,
    //.io_in_1_aw_bits_qos,
    //.io_in_1_w_ready,
    .io_in_1_w_valid        ('d0),
    //.io_in_1_w_bits_data,
    //.io_in_1_w_bits_strb,
    //.io_in_1_w_bits_last,
    .io_in_1_b_ready        ('d0),
    //.io_in_1_b_valid,
    //.io_in_1_b_bits_resp,
    //.io_in_1_b_bits_id,
    //.io_in_1_b_bits_user,
    .io_in_1_ar_ready       (cpu_inst_arready),
    .io_in_1_ar_valid       (cpu_inst_arvalid),
    .io_in_1_ar_bits_addr   (cpu_inst_araddr),
    .io_in_1_ar_bits_prot   ('d0),
    .io_in_1_ar_bits_id      ('d1),
    //.io_in_1_ar_bits_user,
    .io_in_1_ar_bits_len    (cpu_inst_arlen),
    .io_in_1_ar_bits_size   (cpu_inst_arsize),
    .io_in_1_ar_bits_burst  (cpu_inst_arburst),
    .io_in_1_ar_bits_lock   ('d0),
    .io_in_1_ar_bits_cache  ('d0),
    .io_in_1_ar_bits_qos    ('d0),
    .io_in_1_r_ready        (cpu_inst_rready),
    .io_in_1_r_valid        (cpu_inst_rvalid),
    .io_in_1_r_bits_resp    (cpu_inst_rresp),
    .io_in_1_r_bits_data    (cpu_inst_rdata),
    .io_in_1_r_bits_last    (cpu_inst_rlast),
    //.io_in_1_r_bits_id        (),
    //.io_in_1_r_bits_user,
    .io_out_0_aw_ready        (axi_hp0_awready),
    .io_out_0_aw_valid        (axi_hp0_awvalid),
    .io_out_0_aw_bits_addr    (axi_hp0_awaddr),
    .io_out_0_aw_bits_prot    (axi_hp0_awprot),
    .io_out_0_aw_bits_id      (axi_hp0_awid),
    //.io_out_0_aw_bits_user,
    .io_out_0_aw_bits_len     (axi_hp0_awlen),  
    .io_out_0_aw_bits_size    (axi_hp0_awsize),
    .io_out_0_aw_bits_burst   (axi_hp0_awburst),
    .io_out_0_aw_bits_lock    (axi_hp0_awlock),
    .io_out_0_aw_bits_cache   (axi_hp0_awcache),
    .io_out_0_aw_bits_qos     (axi_hp0_awqos),
    .io_out_0_w_ready         (axi_hp0_wready),
    .io_out_0_w_valid         (axi_hp0_wvalid),
    .io_out_0_w_bits_data     (axi_hp0_wdata),
    .io_out_0_w_bits_strb     (axi_hp0_wstrb),
    .io_out_0_w_bits_last     (axi_hp0_wlast),
    .io_out_0_b_ready         (axi_hp0_bready),
    .io_out_0_b_valid         (axi_hp0_bvalid),
    .io_out_0_b_bits_resp     (axi_hp0_bresp),
    .io_out_0_b_bits_id       (axi_hp0_bid),
    //.io_out_0_b_bits_user,
    .io_out_0_ar_ready        (axi_hp0_arready),
    .io_out_0_ar_valid        (axi_hp0_arvalid),
    .io_out_0_ar_bits_addr    (axi_hp0_araddr),
    .io_out_0_ar_bits_prot    (axi_hp0_arprot),
    .io_out_0_ar_bits_id      (axi_hp0_arid),
    //.io_out_0_ar_bits_user,
    .io_out_0_ar_bits_len     (axi_hp0_arlen),
    .io_out_0_ar_bits_size    (axi_hp0_arsize),
    .io_out_0_ar_bits_burst   (axi_hp0_arburst),
    .io_out_0_ar_bits_lock    (axi_hp0_arlock),
    .io_out_0_ar_bits_cache   (axi_hp0_arcache),
    .io_out_0_ar_bits_qos     (axi_hp0_arqos),
    .io_out_0_r_ready         (axi_hp0_rready),
    .io_out_0_r_valid         (axi_hp0_rvalid),
    .io_out_0_r_bits_resp     (axi_hp0_rresp),
    .io_out_0_r_bits_data     (axi_hp0_rdata),
    .io_out_0_r_bits_last     (axi_hp0_rlast),
    .io_out_0_r_bits_id       (axi_hp0_rid)
    //.io_out_0_r_bits_user
  );

  cpu_wrapper	u_cpu_wrapper (
	.cpu_clk			(cpu_clk),
	.cpu_reset		(~cpu_reset_n),

	.cpu_perf_cnt_0 (cpu_perf_cnt_0),
	.cpu_perf_cnt_1 (cpu_perf_cnt_1),
	.cpu_perf_cnt_2 (cpu_perf_cnt_2),
	.cpu_perf_cnt_3 (cpu_perf_cnt_3),
	.cpu_perf_cnt_4 (cpu_perf_cnt_4),
	.cpu_perf_cnt_5 (cpu_perf_cnt_5),
	.cpu_perf_cnt_6 (cpu_perf_cnt_6),
	.cpu_perf_cnt_7 (cpu_perf_cnt_7),
	.cpu_perf_cnt_8 (cpu_perf_cnt_8),
	.cpu_perf_cnt_9 (cpu_perf_cnt_9),
	.cpu_perf_cnt_10 (cpu_perf_cnt_10),
	.cpu_perf_cnt_11 (cpu_perf_cnt_11),
	.cpu_perf_cnt_12 (cpu_perf_cnt_12),
	.cpu_perf_cnt_13 (cpu_perf_cnt_13),
	.cpu_perf_cnt_14 (cpu_perf_cnt_14),
	.cpu_perf_cnt_15 (cpu_perf_cnt_15),
	                      
	.cpu_inst_araddr  (cpu_inst_araddr ),
	.cpu_inst_arready (cpu_inst_arready),
	.cpu_inst_arvalid (cpu_inst_arvalid),
	.cpu_inst_arsize  (cpu_inst_arsize ),
	.cpu_inst_arburst (cpu_inst_arburst),
	.cpu_inst_arlen   (cpu_inst_arlen  ),
	                      
	.cpu_inst_rdata  (cpu_inst_rdata ),
	.cpu_inst_rready (cpu_inst_rready),
	.cpu_inst_rvalid (cpu_inst_rvalid),
	.cpu_inst_rlast  (cpu_inst_rlast ),
	                      
	.cpu_mem_araddr  (cpu_mem_araddr ),
	.cpu_mem_arready (cpu_mem_arready),
	.cpu_mem_arvalid (cpu_mem_arvalid),
	.cpu_mem_arsize  (cpu_mem_arsize ),
	.cpu_mem_arburst (cpu_mem_arburst),
	.cpu_mem_arlen   (cpu_mem_arlen  ),
	                      
	.cpu_mem_awaddr  (cpu_mem_awaddr ),
	.cpu_mem_awready (cpu_mem_awready),
	.cpu_mem_awvalid (cpu_mem_awvalid),
	.cpu_mem_awsize  (cpu_mem_awsize ),
	.cpu_mem_awburst (cpu_mem_awburst),
	.cpu_mem_awlen   (cpu_mem_awlen  ),
	                      
	.cpu_mem_bready (cpu_mem_bready),
	.cpu_mem_bvalid (cpu_mem_bvalid),
	                      
	.cpu_mem_rdata  (cpu_mem_rdata ),
	.cpu_mem_rready (cpu_mem_rready),
	.cpu_mem_rvalid (cpu_mem_rvalid),
	.cpu_mem_rlast  (cpu_mem_rlast ),
	                      
	.cpu_mem_wdata  (cpu_mem_wdata ),
	.cpu_mem_wready (cpu_mem_wready),
	.cpu_mem_wstrb  (cpu_mem_wstrb ),
	.cpu_mem_wvalid (cpu_mem_wvalid),
	.cpu_mem_wlast  (cpu_mem_wlast )
 );

 endmodule
