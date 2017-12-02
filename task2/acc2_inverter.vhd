-- -- -----------------------------------------------------------------------------
-- --
-- --  Title      :  Edge-Detection design project - task 2.
-- --             :
-- --  Developers :  YOUR NAME HERE - s??????@student.dtu.dk
-- --             :  YOUR NAME HERE - s??????@student.dtu.dk
-- --             :
-- --  Purpose    :  This design contains an entity for the accelerator that must be build
-- --             :  in task two of the Edge Detection design project. It contains an
-- --             :  architecture skeleton for the entity as well.
-- --             :
-- --  Revision   :  1.0   ??-??-??     Final version
-- --             :
-- --
-- -- -----------------------------------------------------------------------------
--
-- --------------------------------------------------------------------------------
-- -- The entity for task two. Notice the additional signals for the memory.
-- -- reset is active high.
-- --------------------------------------------------------------------------------
--
-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
-- use IEEE.std_logic_unsigned.all;
-- use work.types.all;
--
-- entity acc is
--     port(
--         clk    : in  bit_t;             -- The clock.
--         reset  : in  bit_t;             -- The reset signal. Active high.
--         addr   : out halfword_t;        -- Address bus for data.
--         dataR  : in  word_t;            -- The data bus.
--         dataW  : out word_t;            -- The data bus.
--         en     : out bit_t;             -- Request signal for data.
--         we     : out bit_t;             -- Read/Write signal for data.
--         start  : in  bit_t;
--         finish : out bit_t
--     );
-- end acc;
--
-- --------------------------------------------------------------------------------
-- -- The desription of the accelerator.
-- --------------------------------------------------------------------------------
--
-- architecture rtl of acc is
--
-- -- All internal signals are defined here
--
-- type inv_states is (ACC_IDLE, ACC_READ, ACC_WRITE);
--
-- signal acc_state : inv_states  := ACC_IDLE;
-- signal acc_next_state : inv_states  := ACC_IDLE;
--
-- constant RAM_BLOCK_SIZE : integer := 50688 - 1;
-- constant WRITE_BLOCK_START_ADDR : halfword_t := x"6300";
--
-- signal write_ptr        : halfword_t := WRITE_BLOCK_START_ADDR;
-- signal next_write_ptr   : halfword_t := WRITE_BLOCK_START_ADDR;
--
-- signal read_ptr         : halfword_t := (others => '0');
-- signal next_read_ptr    : halfword_t := (others => '0');
--
-- signal pixel_out    : word_t :=  (others => '0');
--
-- begin
--
--
-- inv_state_reg : process (reset, clk)
-- begin
--   if (reset = '1') then
--
--     acc_state <= ACC_IDLE;
--     read_ptr <= (others => '0');
--     write_ptr <= (others => '0');
--
--   elsif (rising_edge(clk)) then
--
--     acc_state <= acc_next_state;
--     read_ptr <= next_read_ptr;
--     write_ptr <= next_write_ptr;
--
--   end if;
-- end process inv_state_reg;
--
--
-- inv_state_logic : process (acc_state, start)
-- begin
--
--   acc_next_state <= acc_state;
--   we <= '0';
--   en <= '1';
--   finish <= '0';
--
--   case(acc_state) is
--
--     when ACC_IDLE =>
--
--       en <= '0';
--
--       if start = '1' then
--         acc_next_state <= ACC_READ;
--       end if;
--
--     when ACC_READ =>
--
--       we <= '0';
--       next_read_ptr <= read_ptr + 1;
--       acc_next_state <= ACC_WRITE;
--       addr <= read_ptr;
--       dataW <= pixel_out;
--
--     when ACC_WRITE =>
--
--       we <= '1';
--       addr <= write_ptr;
--       next_write_ptr <= write_ptr + 1;
--       pixel_out <= (x"FFFFFFFF" - dataR);
--
--       if write_ptr = RAM_BLOCK_SIZE then
--         acc_next_state <= ACC_IDLE;
--         finish <= '1';
--       end if;
--
--       acc_next_state <= ACC_READ;
--
--     when others =>
--     null;
--
--   end case;
--
--
-- end process inv_state_logic;
--
--
--
-- -- Template for a process
-- --    myprocess : process(clk)
-- --        if rising_edge(clk) then
-- --            if reset = '1' then
-- --                -- Registers reset
-- --            else
-- --                -- Registers update
-- --            end if;
-- --        end if;
-- --    end process myprocess;
--
-- end rtl;






















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

type inv_states is (ACC_IDLE, ACC_READ, ACC_CALC, ACC_WRITE, ACC_END);

signal acc_state : inv_states  := ACC_IDLE;
signal acc_next_state : inv_states  := ACC_IDLE;

constant RAM_BLOCK_SIZE : integer := 50688 - 1;
constant WRITE_BLOCK_START_ADDR : halfword_t := x"6300";

signal write_ptr        : halfword_t := WRITE_BLOCK_START_ADDR;
signal next_write_ptr   : halfword_t := WRITE_BLOCK_START_ADDR;

signal read_ptr         : halfword_t := (others => '0');
signal next_read_ptr    : halfword_t := (others => '0');

signal pixel_out    : word_t :=  (others => '0');
signal next_pixel_out: word_t:= (others=>'0');

signal pixel_in    : word_t :=  (others => '0');
signal next_pixel_in: word_t:= (others=>'0');


begin

      dataW <= (x"FFFFFFFF" - dataR);--pixel_out;

inv_state_reg : process (reset, clk)
begin
 if (rising_edge(clk)) then

   if (reset = '1' ) then
     acc_state <= ACC_IDLE;
     read_ptr <= (others => '0');
     write_ptr <= WRITE_BLOCK_START_ADDR;
     pixel_in <= (others => '0');
   --pixel_out <= (others =>'0');
   else
      acc_state <= acc_next_state;
      read_ptr <= next_read_ptr;
      write_ptr <= next_write_ptr;
    	pixel_in <= next_pixel_in;
    	--pixel_out <= next_pixel_out;
    end if;

  end if;
end process inv_state_reg;


inv_state_logic : process (acc_state, start,write_ptr, read_ptr)
begin

  acc_next_state <= acc_state;
  we <= '0';
  en <= '1';
  finish <= '0';
  next_write_ptr<=write_ptr;
  next_read_ptr<=read_ptr;
  addr<=read_ptr;
  --next_pixel_out<=pixel_out;-- <= (x"FFFFFFFF" - dataR);

  case(acc_state) is

    when ACC_IDLE =>

      en <= '0';

      if start = '1' then
        acc_next_state <= ACC_READ;
      end if;


    when ACC_READ =>

      we <= '0';
      next_read_ptr <= read_ptr + 1;
      acc_next_state <= ACC_WRITE;
      addr <= read_ptr;
      -- dataW <= pixel_out;

    when ACC_WRITE =>

      we <= '1';
      addr <= write_ptr;
      next_write_ptr <= write_ptr + 1;
      -- pixel_out <= (x"FFFFFFFF" - dataR);

      acc_next_state <= ACC_READ;

      if write_ptr = RAM_BLOCK_SIZE then
        acc_next_state <= ACC_END;
        -- finish <= '1';
      end if;

      when ACC_END =>
        finish <= '1';
      if start = '1' then
          -- acc_next_state <= ACC_IDLE;
      end if;

    when others =>
    null;

  end case;


end process inv_state_logic;



-- Template for a process
--    myprocess : process(clk)
--        if rising_edge(clk) then
--            if reset = '1' then
--                -- Registers reset
--            else
--                -- Registers update
--            end if;
--        end if;
--    end process myprocess;

end rtl;
