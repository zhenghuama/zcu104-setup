set origin_dir "."
set _xil_proj_name_ "zcu104_irq_io"

create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xczu7ev-ffvc1156-2-e
set proj_dir [get_property directory [current_project]]

set obj [current_project]
set_property -name "board_part" -value "xilinx.com:zcu104:part0:1.1" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_resource_estimation" -value "0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "zcu104" -objects $obj
set_property -name "platform.default_output_type" -value "sd_card" -objects $obj
set_property -name "platform.design_intent.datacenter" -value "false" -objects $obj
set_property -name "platform.design_intent.embedded" -value "true" -objects $obj
set_property -name "platform.design_intent.external_host" -value "false" -objects $obj
set_property -name "platform.design_intent.server_managed" -value "false" -objects $obj
set_property -name "platform.extensible" -value "1" -objects $obj
set_property -name "platform.name" -value "name" -objects $obj
set_property -name "revised_directory_structure" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "sim_compile_state" -value "1" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj

set obj [get_filesets sources_1]
set files [list \
 [file normalize "${origin_dir}/rtl/irq_pl.v" ]\
]
set imported_files [import_files -fileset sources_1 $files]
set obj [get_filesets sources_1]
set_property -name "top" -value "design_1_wrapper" -objects $obj


set obj [get_filesets sim_1]
set_property -name "top" -value "design_1_wrapper" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj

proc cr_bd_design_1 { parentCell } {
# The design that will be created by this Tcl proc contains the following 
# module references:
# irq_pl



  # CHANGE DESIGN NAME HERE
  set design_name design_1

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:axi_dma:7.1\
  xilinx.com:ip:axi_gpio:2.0\
  xilinx.com:ip:smartconnect:1.0\
  xilinx.com:ip:axis_data_fifo:2.0\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:system_ila:1.1\
  xilinx.com:ip:xlconcat:2.1\
  xilinx.com:ip:zynq_ultra_ps_e:3.4\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  ##################################################################
  # CHECK Modules
  ##################################################################
  set bCheckModules 1
  if { $bCheckModules == 1 } {
     set list_check_mods "\ 
  irq_pl\
  "

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property CONFIG.c_include_sg {0} $axi_dma_0


  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_gpio_0


  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property CONFIG.NUM_SI {2} $axi_smc


  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]

  # Create instance: irq_pl_0, and set properties
  set block_name irq_pl
  set block_cell_name irq_pl_0
  if { [catch {set irq_pl_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $irq_pl_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: ps8_0_axi_periph, and set properties
  set ps8_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_axi_periph ]
  set_property CONFIG.NUM_MI {2} $ps8_0_axi_periph


  # Create instance: rst_ps8_0_96M, and set properties
  set rst_ps8_0_96M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_96M ]

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {INTERFACE} \
    CONFIG.C_NUM_MONITOR_SLOTS {4} \
    CONFIG.C_SLOT_0_APC_EN {0} \
    CONFIG.C_SLOT_0_AXI_AR_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_AR_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_AXI_AW_SEL_DATA {0} \
    CONFIG.C_SLOT_0_AXI_AW_SEL_TRIG {0} \
    CONFIG.C_SLOT_0_AXI_B_SEL_DATA {0} \
    CONFIG.C_SLOT_0_AXI_B_SEL_TRIG {0} \
    CONFIG.C_SLOT_0_AXI_R_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_R_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_AXI_W_SEL_DATA {0} \
    CONFIG.C_SLOT_0_AXI_W_SEL_TRIG {0} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
    CONFIG.C_SLOT_1_APC_EN {0} \
    CONFIG.C_SLOT_1_AXI_AR_SEL_DATA {0} \
    CONFIG.C_SLOT_1_AXI_AR_SEL_TRIG {0} \
    CONFIG.C_SLOT_1_AXI_AW_SEL_DATA {1} \
    CONFIG.C_SLOT_1_AXI_AW_SEL_TRIG {1} \
    CONFIG.C_SLOT_1_AXI_B_SEL_DATA {1} \
    CONFIG.C_SLOT_1_AXI_B_SEL_TRIG {1} \
    CONFIG.C_SLOT_1_AXI_R_SEL_DATA {0} \
    CONFIG.C_SLOT_1_AXI_R_SEL_TRIG {0} \
    CONFIG.C_SLOT_1_AXI_W_SEL_DATA {1} \
    CONFIG.C_SLOT_1_AXI_W_SEL_TRIG {1} \
    CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
    CONFIG.C_SLOT_2_APC_EN {0} \
    CONFIG.C_SLOT_2_AXI_DATA_SEL {1} \
    CONFIG.C_SLOT_2_AXI_TRIG_SEL {1} \
    CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.C_SLOT_3_APC_EN {0} \
    CONFIG.C_SLOT_3_AXI_DATA_SEL {1} \
    CONFIG.C_SLOT_3_AXI_TRIG_SEL {1} \
    CONFIG.C_SLOT_3_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  ] $system_ila_0


  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $xlconcat_0


  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 zynq_ultra_ps_e_0 ]
  set_property -dict [list \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_DDR_RAM_HIGHADDR {0x7FFFFFFF} \
    CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x00000002} \
    CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
    CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Feedback Clk##########I2C 1#I2C 1#UART 0#UART 0#UART 1#UART 1###CAN 1#CAN\
1##DPAUX#DPAUX#DPAUX#DPAUX###############SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem\
3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
    CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#clk_for_lpbk##########scl_out#sda_out#rxd#txd#txd#rxd###phy_tx#phy_rx##dp_aux_data_out#dp_hot_plug_detect#dp_aux_data_oe#dp_aux_data_in###############sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out}\
\
    CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
    CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
    CONFIG.PSU__ACT_DDR_FREQ_MHZ {1050.000000} \
    CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
    CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__CAN1__PERIPHERAL__IO {MIO 24 .. 25} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1200.000000} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {525.000000} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1067} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {600.000000} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__ACT_FREQMHZ {25.000000} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_AUDIO__FRAC_ENABLED {0} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__ACT_FREQMHZ {26.785715} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__ACT_FREQMHZ {300.000000} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO__FRAC_ENABLED {0} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {600.000000} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {500.000000} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {525.000000} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {500.000000} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {50.000000} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {500.000000} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1500.000000} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {125.000000} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {500.000000} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.500000} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {125.000000} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {187.500000} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {250.000000} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {20.000000} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__FREQMHZ {20} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
    CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
    CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
    CONFIG.PSU__DDRC__CL {15} \
    CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
    CONFIG.PSU__DDRC__COMPONENTS {Components} \
    CONFIG.PSU__DDRC__CWL {14} \
    CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
    CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
    CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {4096 MBits} \
    CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
    CONFIG.PSU__DDRC__ECC {Disabled} \
    CONFIG.PSU__DDRC__FGRM {1X} \
    CONFIG.PSU__DDRC__LP_ASR {manual normal} \
    CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
    CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
    CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
    CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {15} \
    CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2133P} \
    CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
    CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
    CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
    CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
    CONFIG.PSU__DDRC__T_FAW {30.0} \
    CONFIG.PSU__DDRC__T_RAS_MIN {33} \
    CONFIG.PSU__DDRC__T_RC {47.06} \
    CONFIG.PSU__DDRC__T_RCD {15} \
    CONFIG.PSU__DDRC__T_RP {15} \
    CONFIG.PSU__DDRC__VREF {1} \
    CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {0} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {533.500} \
    CONFIG.PSU__DISPLAYPORT__LANE0__ENABLE {1} \
    CONFIG.PSU__DISPLAYPORT__LANE0__IO {GT Lane1} \
    CONFIG.PSU__DISPLAYPORT__LANE1__ENABLE {1} \
    CONFIG.PSU__DISPLAYPORT__LANE1__IO {GT Lane0} \
    CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__DLL__ISUSED {1} \
    CONFIG.PSU__DPAUX__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__DPAUX__PERIPHERAL__IO {MIO 27 .. 30} \
    CONFIG.PSU__DP__LANE_SEL {Dual Lower} \
    CONFIG.PSU__DP__REF_CLK_FREQ {27} \
    CONFIG.PSU__DP__REF_CLK_SEL {Ref Clk3} \
    CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
    CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
    CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
    CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
    CONFIG.PSU__ENET3__PTP__ENABLE {0} \
    CONFIG.PSU__ENET3__TSU__ENABLE {0} \
    CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
    CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__FTM__CTI_OUT_0 {0} \
    CONFIG.PSU__FTM__GPO {0} \
    CONFIG.PSU__GEM3_COHERENCY {0} \
    CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__GEM__TSU__ENABLE {0} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__GT__LINK_SPEED {HBR} \
    CONFIG.PSU__GT__PRE_EMPH_LVL_4 {0} \
    CONFIG.PSU__GT__VLT_SWNG_LVL_4 {0} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 16 .. 17} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
    CONFIG.PSU__PL_CLK0_BUF {TRUE} \
    CONFIG.PSU__PRESET_APPLIED {1} \
    CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;1|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;0|SATA1:NonSecure;1|SATA0:NonSecure;1|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;1|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
    CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;0|FPD;SATA;FD0C0000;FD0CFFFF;1|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;0|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;1|FPD;DPDMA;FD4C0000;FD4CFFFF;1|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;800000000;0|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;1|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333333} \
    CONFIG.PSU__QSPI_COHERENCY {0} \
    CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
    CONFIG.PSU__QSPI__GRP_FBCLK__IO {MIO 6} \
    CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 5} \
    CONFIG.PSU__QSPI__PERIPHERAL__MODE {Single} \
    CONFIG.PSU__SATA__LANE0__ENABLE {0} \
    CONFIG.PSU__SATA__LANE1__IO {GT Lane3} \
    CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SATA__REF_CLK_FREQ {125} \
    CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk1} \
    CONFIG.PSU__SAXIGP2__DATA_WIDTH {128} \
    CONFIG.PSU__SD1_COHERENCY {0} \
    CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__SD1__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD1__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
    CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
    CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
    CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
    CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
    CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
    CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
    CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
    CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
    CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
    CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__UART0__BAUD_RATE {115200} \
    CONFIG.PSU__UART0__MODEM__ENABLE {0} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 18 .. 19} \
    CONFIG.PSU__UART1__BAUD_RATE {115200} \
    CONFIG.PSU__UART1__MODEM__ENABLE {0} \
    CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 20 .. 21} \
    CONFIG.PSU__USB0_COHERENCY {0} \
    CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
    CONFIG.PSU__USB0__REF_CLK_FREQ {26} \
    CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
    CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
    CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
    CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
    CONFIG.PSU__USB__RESET__MODE {Boot Pin} \
    CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
    CONFIG.PSU__USE__IRQ0 {1} \
    CONFIG.PSU__USE__M_AXI_GP0 {1} \
    CONFIG.PSU__USE__M_AXI_GP1 {0} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
    CONFIG.PSU__USE__S_AXI_GP2 {1} \
  ] $zynq_ultra_ps_e_0


  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
connect_bd_intf_net -intf_net [get_bd_intf_nets axi_dma_0_M_AXIS_MM2S] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins system_ila_0/SLOT_2_AXIS]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axi_dma_0_M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_smc/S00_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets axi_dma_0_M_AXI_MM2S] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins system_ila_0/SLOT_0_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axi_dma_0_M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_smc/S01_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets axi_dma_0_M_AXI_S2MM] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins system_ila_0/SLOT_1_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axi_dma_0_M_AXI_S2MM]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
connect_bd_intf_net -intf_net [get_bd_intf_nets axis_data_fifo_0_M_AXIS] [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins system_ila_0/SLOT_3_AXIS]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axis_data_fifo_0_M_AXIS]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins ps8_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_LPD [get_bd_intf_pins ps8_0_axi_periph/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]

  # Create port connections
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins irq_pl_0/irq_in]
  connect_bd_net -net irq_pl_0_irq_out [get_bd_pins irq_pl_0/irq_out] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net rst_ps8_0_96M_peripheral_aresetn [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_smc/aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins ps8_0_axi_periph/ARESETN] [get_bd_pins ps8_0_axi_periph/M00_ARESETN] [get_bd_pins ps8_0_axi_periph/M01_ARESETN] [get_bd_pins ps8_0_axi_periph/S00_ARESETN] [get_bd_pins rst_ps8_0_96M/peripheral_aresetn] [get_bd_pins system_ila_0/resetn]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins irq_pl_0/clk] [get_bd_pins ps8_0_axi_periph/ACLK] [get_bd_pins ps8_0_axi_periph/M00_ACLK] [get_bd_pins ps8_0_axi_periph/M01_ACLK] [get_bd_pins ps8_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps8_0_96M/slowest_sync_clk] [get_bd_pins system_ila_0/clk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins rst_ps8_0_96M/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI] -force
  assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA0010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM]


  # Restore current instance
  current_bd_instance $oldCurInst

  # Create PFM attributes
  set_property PFM_NAME {xilinx:zcu104:name:0.0} [get_files [current_bd_design].bd]
  set_property PFM.CLOCK {pl_clk0 {id "0" is_default "true" proc_sys_reset "/rst_ps8_0_96M" status "fixed" freq_hz "96968727"}} [get_bd_cells /zynq_ultra_ps_e_0]


  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_design_1()

cr_bd_design_1 ""
set_property PFM_NAME "xilinx:zcu104:name:0.0" [get_files design_1.bd ] 
set_property REGISTERED_WITH_MANAGER "1" [get_files design_1.bd ] 
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files design_1.bd ] 

#call make_wrapper to create wrapper files
if { [get_property IS_LOCKED [ get_files -norecurse design_1.bd] ] == 1  } {
  import_files -fileset sources_1 [file normalize "${origin_dir}/zcu104_irq_io.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v" ]
} else {
  set wrapper_path [make_wrapper -fileset sources_1 -files [ get_files -norecurse design_1.bd] -top]
  add_files -norecurse -fileset sources_1 $wrapper_path
}


set idrFlowPropertiesConstraints ""
catch {
 set idrFlowPropertiesConstraints [get_param runs.disableIDRFlowPropertyConstraints]
 set_param runs.disableIDRFlowPropertyConstraints 1
}

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part xczu7ev-ffvc1156-2-e -flow {Vivado Synthesis 2022} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2022" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part xczu7ev-ffvc1156-2-e -flow {Vivado Implementation 2022} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2022" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj

# set the current impl run
current_run -implementation [get_runs impl_1]
catch {
 if { $idrFlowPropertiesConstraints != {} } {
   set_param runs.disableIDRFlowPropertyConstraints $idrFlowPropertiesConstraints
 }
}

puts "INFO: Project created:${_xil_proj_name_}"

reset_run impl_1
reset_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 16

wait_on_run -timeout 360 impl_1

update_compile_order -fileset sources_1
#set_property pfm_name {xilinx:zcu104:name:0.0} [get_files -all {./${_xil_proj_name_}/./${_xil_proj_name_}.srcs/sources_1/bd/design_1/design_1.bd}]
set_property platform.uses_pr {false} [current_project]
write_hw_platform -hw -include_bit -force -file ./${_xil_proj_name_}/zcu104_irq_wrapper.xsa
