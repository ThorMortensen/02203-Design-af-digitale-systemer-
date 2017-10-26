-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  YOUR NAME HERE - s??????@student.dtu.dk
--             :  YOUR NAME HERE - s??????@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be build
--             :  in task two of the Edge Detection design project. It contains an
--             :  architecture skeleton for the entity as well.
--             :
--  Revision   :  1.0   ??-??-??     Final version
--             :
--
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- The entity for task two. Notice the additional signals for the memory.
-- reset is active high.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity acc is
    port(
        clk    : in  bit_t;             -- The clock.
        reset  : in  bit_t;             -- The reset signal. Active high.
        addr   : out halfword_t;        -- Address bus for data.
        dataR  : in  word_t;            -- The data bus.
        dataW  : out word_t;            -- The data bus.
        en     : out bit_t;             -- Request signal for data.
        we     : out bit_t;             -- Read/Write signal for data.
        start  : in  bit_t;
        finish : out bit_t
    );
end acc;

--------------------------------------------------------------------------------
-- The desription of the accelerator.
--------------------------------------------------------------------------------

architecture rtl of acc is

-- All internal signals are defined here

type inv_states is (ACC_IDLE, ACC_LOAD1,ACC_LOAD2, ACC_LOAD3, ACC_WRITE, ACC_SHIFT, ACC_LOAD_NEW, RE_CAL_OFFSETS);
type convolution_arr_t is array(0 to 2) of std_logic_vector(2 downto 0);

signal acc_state : inv_states  := ACC_IDLE;
signal acc_next_state : inv_states  := ACC_IDLE;

constant RAM_BLOCK_SIZE : integer := 50688 - 1; 
constant WRITE_BLOCK_START_ADDR : halfword_t := x"6300"; 
constant STRIDE_OFFSET1 : halfword_t := x"58" - 1;  -- 352 x 288
constant STRIDE_OFFSET2 : halfword_t := x"B0" - 1;  -- 352 x 288


signal write_ptr        : halfword_t := WRITE_BLOCK_START_ADDR;
signal next_write_ptr   : halfword_t := WRITE_BLOCK_START_ADDR;

signal read_ptr         : halfword_t := (others => '0');
signal next_read_ptr    : halfword_t := (others => '0');

signal pixel_out    : word_t :=  (others => '0');

signal convolution_arr : convolution_arr_t := (others => (others => '0'));

begin


inv_state_reg : process (reset, clk)
begin
  if (reset = '1') then

    acc_state <= ACC_IDLE;
    read_ptr <= (others => '0');
    write_ptr <= (others => '0');

  elsif (rising_edge(clk)) then

    acc_state <= acc_next_state;
    read_ptr <= next_read_ptr;
    write_ptr <= next_write_ptr;

  end if;
end process inv_state_reg;


inv_state_logic : process (acc_state, start)
begin

  acc_next_state <= acc_state;
  we <= '0';
  en <= '1';
  finish <= '0';

  case(acc_state) is

    when ACC_IDLE =>
      
      en <= '0';

      if start = '1' then 
        acc_next_state <= ACC_LOAD1;
        addr <= read_ptr;
      end if;

    when ACC_LOAD1 =>

      we <= '0';
      acc_next_state <= ACC_WRITE;
      addr <= read_ptr + STRIDE_OFFSET1;
      convolution_arr(0) <= dataR;

    when ACC_LOAD2 =>
    
      we <= '0';
      acc_next_state <= ACC_WRITE;
      addr <= read_ptr + STRIDE_OFFSET2;
      convolution_arr(1) <= dataR;

    when ACC_LOAD3 =>

      we <= '0';
      acc_next_state <= ACC_WRITE;
      addr <= write_ptr;
      convolution_arr(2) <= dataR;

    when ACC_WRITE =>

      we <= '1'; 
      addr <= write_ptr;
      next_write_ptr <= write_ptr + 1;
      pixel_out <= (x"FFFFFFFF" - dataR);

      if write_ptr = RAM_BLOCK_SIZE then 
        acc_next_state <= ACC_IDLE;
        finish <= '1';
      end if;

      acc_next_state <= ACC_READ;

    when ACC_SHIFT =>
    when ACC_LOAD_NEW =>
    when RE_CAL_OFFSETS =>

    when others =>
    null;

  end case;

  
end process inv_state_logic;

end rtl;
