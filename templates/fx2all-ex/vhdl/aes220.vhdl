--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.1
--  \   \         Application : xaw2vhdl
--  /   /         Filename : clk_gen.vhd
-- /___/   /\     Timestamp : 03/19/2013 22:48:11
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-st /home/chris/build/makestuff/libs/libfpgalink/hdl/apps/makestuff/readback/vhdl/x3/./clk_gen.xaw /home/chris/build/makestuff/libs/libfpgalink/hdl/apps/makestuff/readback/vhdl/x3/./clk_gen
--Design Name: clk_gen
--Device: xc3s200a-4ft256
--
-- Module clk_gen
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity clk_gen is
   port ( clk_in        : in    std_logic; 

          clk000_out        : out   std_logic; 
          clk180_out      : out   std_logic; 
          locked_out      : out   std_logic);
end clk_gen;

architecture BEHAVIORAL of clk_gen is
   signal CLKFB_IN        : std_logic;
   signal CLKIN_IBUFG     : std_logic;
   signal CLK0_BUF        : std_logic;
   signal CLK180_BUF      : std_logic;
   signal GND_BIT         : std_logic;
begin
   GND_BIT <= '0';

   clk000_out <= CLKFB_IN;
   CLKIN_IBUFG_INST : IBUFG
      port map (I=>clk_in,
                O=>CLKIN_IBUFG);
   
   CLK0_BUFG_INST : BUFG
      port map (I=>CLK0_BUF,
                O=>CLKFB_IN);
   
   CLK180_BUFG_INST : BUFG
      port map (I=>CLK180_BUF,
                O=>clk180_out);

   DCM_SP_INST : DCM_SP
   generic map( CLK_FEEDBACK => "1X",
            CLKDV_DIVIDE => 2.0,
            CLKFX_DIVIDE => 1,
            CLKFX_MULTIPLY => 4,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => 20.833,
            CLKOUT_PHASE_SHIFT => "NONE",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "LOW",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"C080",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => FALSE)
      port map (CLKFB=>CLKFB_IN,
                CLKIN=>CLKIN_IBUFG,
                DSSEN=>GND_BIT,
                PSCLK=>GND_BIT,
                PSEN=>GND_BIT,
                PSINCDEC=>GND_BIT,
                RST=>GND_BIT,
                CLKDV=>open,
                CLKFX=>open,
                CLKFX180=>open,
                CLK0=>CLK0_BUF,
                CLK2X=>open,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>CLK180_BUF,
                CLK270=>open,
                LOCKED=>locked_out,
                PSDONE=>open,
                STATUS=>open);
   
end BEHAVIORAL;


