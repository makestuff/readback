--
-- Copyright (C) 2009-2012 Chris McClelland
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_ctrl_pkg.all;

architecture structural of sdram is
	-- 8-bit Command Pipe (FIFO -> 8to16)
	signal cmd8Data   : std_logic_vector(7 downto 0);
	signal cmd8Valid  : std_logic;
	signal cmd8Ready  : std_logic;
	
	-- 16-bit Command Pipe (8to16 -> MemPipe)
	signal cmd16Data  : std_logic_vector(15 downto 0);
	signal cmd16Valid : std_logic;
	signal cmd16Ready : std_logic;

	-- 16-bit Response Pipe (MemPipe -> 16to8)
	signal rsp16Data  : std_logic_vector(15 downto 0);
	signal rsp16Valid : std_logic;
	signal rsp16Ready : std_logic;

	-- 8-bit Response Pipe (16to8 -> FIFO)
	signal rsp8Data   : std_logic_vector(7 downto 0);
	signal rsp8Valid  : std_logic;
	signal rsp8Ready  : std_logic;

	-- Memory controller interface
	signal mcReady    : std_logic;
	signal mcCmd      : MCCmdType;
	signal mcAddr     : std_logic_vector(22 downto 0);
	signal mcDataWr   : std_logic_vector(15 downto 0);
	signal mcDataRd   : std_logic_vector(15 downto 0);
	signal mcRDV      : std_logic;
begin
	-- Command Pipe FIFO
	cmd_fifo: entity work.fifo
		generic map(
			WIDTH => 8,
			DEPTH => 2
		)
		port map(
			clk_in          => clk_in,
			reset_in        => '0',
			depth_out       => open,

			-- Input pipe
			inputData_in    => h2fData_in,
			inputValid_in   => h2fValid_in,
			inputReady_out  => h2fReady_out,

			-- Output pipe
			outputData_out  => cmd8Data,
			outputValid_out => cmd8Valid,
			outputReady_in  => cmd8Ready
		);

	-- Command Pipe 8->16 converter
	cmd_conv: entity work.conv_8to16
		port map(
			clk_in       => clk_in,
			reset_in     => '0',
			data8_in     => cmd8Data,
			valid8_in    => cmd8Valid,
			ready8_out   => cmd8Ready,
			data16_out   => cmd16Data,
			valid16_out  => cmd16Valid,
			ready16_in   => cmd16Ready
		);

	-- Memory Pipe Unit (connects command & response pipes to the memory controller)
	mem_pipe: entity work.mem_pipe
		port map(
			clk_in       => clk_in,
			reset_in     => reset_in,

			-- Command pipe
			cmdData_in   => cmd16Data,
			cmdValid_in  => cmd16Valid,
			cmdReady_out => cmd16Ready,

			-- Response pipe
			rspData_out  => rsp16Data,
			rspValid_out => rsp16Valid,
			rspReady_in  => rsp16Ready,

			-- Memory controller interface
			mcReady_in   => mcReady,
			mcCmd_out    => mcCmd,
			mcAddr_out   => mcAddr,
			mcData_out   => mcDataWr,
			mcData_in    => mcDataRd,
			mcRDV_in     => mcRDV
		);

	-- Response Pipe 16->8 converter
	rsp_conv: entity work.conv_16to8
		port map(
			clk_in      => clk_in,
			reset_in    => '0',
			data16_in   => rsp16Data,
			valid16_in  => rsp16Valid,
			ready16_out => rsp16Ready,
			data8_out   => rsp8Data,
			valid8_out  => rsp8Valid,
			ready8_in   => rsp8Ready
		);

	-- Response Pipe FIFO
	rsp_fifo: entity work.fifo
		generic map(
			WIDTH => 8,
			DEPTH => 2
		)
		port map(
			clk_in          => clk_in,
			reset_in        => '0',
			depth_out       => open,

			-- Input pipe
			inputData_in    => rsp8Data,
			inputValid_in   => rsp8Valid,
			inputReady_out  => rsp8Ready,

			-- Output pipe
			outputData_out  => f2hData_out,
			outputValid_out => f2hValid_out,
			outputReady_in  => f2hReady_in
		);
	
	-- Memory controller (connects SDRAM to Memory Pipe Unit)
	mem_ctrl: entity work.mem_ctrl
		generic map(
			INIT_COUNT     => "1" & x"2C0",  --\
			REFRESH_DELAY  => "0" & x"300",  -- Much longer in real hardware!
			REFRESH_LENGTH => "0" & x"002"   --/
		)
		port map(
			clk_in       => clk_in,
			reset_in     => reset_in,

			-- Client interface
			mcAutoMode_in => '1',
			mcReady_out   => mcReady,
			mcCmd_in      => mcCmd,
			mcAddr_in     => mcAddr,
			mcData_in     => mcDataWr,
			mcData_out    => mcDataRd,
			mcRDV_out     => mcRDV,

			-- SDRAM interface
			ramCmd_out    => ramCmd_out,
			ramBank_out   => ramBank_out,
			ramAddr_out   => ramAddr_out,
			ramData_io    => ramData_io,
			ramLDQM_out   => ramLDQM_out,
			ramUDQM_out   => ramUDQM_out
		);

end architecture;
