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

  constant IMG_HIGHT          : integer := 288;
  constant IMG_WIDTH          : integer := 352;

  constant IMG_BUF_DEPTH      : integer := 3 - 1;
  constant IMG_BUF_WIDTH      : integer := (IMG_WIDTH / 4) - 1; -- 4 pixels (bytes pr word)
  constant IMG_BIT_COL_WIDH   : integer := (IMG_WIDTH * 8) - 1; -- 8 bits per pixel (byte)

  constant RAM_BLOCK_SIZE : integer := 50688 - 1;
  constant WRITE_BLOCK_START_ADDR : halfword_t := x"6300";


-- All internal signals are defined here
type inv_states is (ACC_IDLE, ACC_INIT, ACC_CALC, ACC_INIT_SHIFT_IN, ACC_INIT_SHIFT_UP, ACC_SHIFT_IN, ACC_SHIFT_UP, ACC_WRITE);
type img_calc_buf_t is array (0 to IMG_BUF_DEPTH) of std_logic_vector(IMG_BIT_COL_WIDH downto 0);

signal acc_state : inv_states  := ACC_IDLE;
signal next_acc_state : inv_states  := ACC_IDLE;

signal write_ptr        : halfword_t := WRITE_BLOCK_START_ADDR;
signal next_write_ptr   : halfword_t := WRITE_BLOCK_START_ADDR;

signal read_ptr         : halfword_t := (others => '0');
signal next_read_ptr    : halfword_t := (others => '0');

signal img_result_reg : std_logic_vector(IMG_BIT_COL_WIDH downto 0) := (others => '0');
signal img_calc_buf   : img_calc_buf_t := (others => (others => '0'));

signal pixel_in       : word_t :=  (others => '0');

signal img_shift_in_en : std_logic := '0';
signal img_shift_up_en : std_logic := '0';

signal img_shift_in_cntr      : natural range 0 to IMG_BUF_WIDTH := 0;
signal next_img_shift_in_cntr : natural range 0 to IMG_BUF_WIDTH := 0;
signal img_shift_up_cntr      : natural range 0 to IMG_HIGHT     := 0;
signal next_img_shift_up_cntr : natural range 0 to IMG_HIGHT     := 0;

signal calc_en                : std_logic := '0';

signal result_shift_en : std_logic := '0';
signal we_intl : std_logic := '0';


-- signal img_shift_up_init_done : std_logic is std_logic_vector(to_unsigned(img_shift_up_cntr, 2 ));

alias img_result_word : word_t is img_result_reg(IMG_BIT_COL_WIDH downto IMG_BIT_COL_WIDH - 31);

begin

shift_in : process(clk)
begin
  if rising_edge(clk) then
    if img_shift_in_en = '1' then
      img_calc_buf(0) <= img_calc_buf(0)(IMG_BIT_COL_WIDH - 32 downto 0) & pixel_in;
    end if;
  end if;
end process;

shift_up : process(clk)
begin
  if rising_edge(clk) then
    if img_shift_up_en = '1' then
      img_calc_buf(IMG_BUF_DEPTH)      <= img_calc_buf(IMG_BUF_DEPTH - 1);
      img_calc_buf(IMG_BUF_DEPTH - 1)  <= img_calc_buf(IMG_BUF_DEPTH - 2);
    end if;
  end if;
end process;

sobel_reg : process(clk)
begin
  if rising_edge(clk) then
    if calc_en = '1' then
      img_result_reg <= img_calc_buf(1);
    elsif result_shift_en = '1' then
      img_result_reg <= img_result_reg(IMG_BIT_COL_WIDH - 32 downto 0) & x"00000000";
    end if;
  end if;
end process;


inv_state_reg : process (reset, clk)
begin
  if (reset = '1') then

    acc_state         <= ACC_IDLE;
    read_ptr          <= (others => '0');
    write_ptr         <= (others => '0');
    img_shift_in_cntr <= 0;
    img_shift_up_cntr <= 0;

  elsif (rising_edge(clk)) then

    acc_state         <= next_acc_state;
    read_ptr          <= next_read_ptr;
    write_ptr         <= next_write_ptr;
    img_shift_in_cntr <= next_img_shift_in_cntr;
    img_shift_up_cntr <= next_img_shift_up_cntr;

  end if;
end process inv_state_reg;

addr <= write_ptr when we_intl = '1' else read_ptr;
dataW <= img_result_word;
we <= we_intl;

inv_state_logic : process (acc_state, start, img_shift_up_cntr, img_shift_in_cntr)
begin

  next_acc_state          <= acc_state        ;
  next_read_ptr           <= read_ptr         ;
  next_write_ptr          <= write_ptr        ;
  next_img_shift_in_cntr  <= img_shift_in_cntr;
  next_img_shift_up_cntr  <= img_shift_up_cntr;

  we_intl <= '0';
  en <= '1';
  finish <= '0';

  img_shift_in_en <= '0';
  img_shift_up_en <= '0';
  result_shift_en <= '0';

  case(acc_state) is

    when ACC_IDLE =>

      en <= '0';
      next_img_shift_up_cntr <= 0;

      if start = '1' then
        next_acc_state <= ACC_INIT;
      end if;

    when ACC_INIT =>

      if img_shift_up_cntr = 3 then
        next_acc_state <= ACC_CALC;
      else
        next_img_shift_up_cntr  <= img_shift_up_cntr + 1;
        next_acc_state          <= ACC_INIT_SHIFT_IN;
      end if;

      next_img_shift_in_cntr  <= 0;

    when ACC_INIT_SHIFT_IN =>

      if img_shift_in_cntr = IMG_BUF_WIDTH then
        next_acc_state <= ACC_INIT_SHIFT_UP;
      else
        next_img_shift_in_cntr <= img_shift_in_cntr + 1;
        next_read_ptr <= read_ptr + 1;
        pixel_in <= dataR;
        img_shift_in_en <= '1';
      end if;

    when ACC_INIT_SHIFT_UP =>

      img_shift_up_en <= '1';
      next_acc_state <= ACC_INIT;

    when ACC_CALC =>

      calc_en <= '1';
      next_acc_state <= ACC_WRITE;
      next_img_shift_in_cntr <= 0;


    when ACC_SHIFT_IN =>

      if img_shift_in_cntr = IMG_BUF_WIDTH then
        next_acc_state <= ACC_CALC;
      else
        next_img_shift_in_cntr <= img_shift_in_cntr + 1;
        next_read_ptr <= read_ptr + 1;
        pixel_in <= dataR;
        img_shift_in_en <= '1';
      end if;

    when ACC_SHIFT_UP =>

      img_shift_up_en <= '1';
      next_acc_state <= ACC_SHIFT_IN;
      next_img_shift_in_cntr <= 0;

    when ACC_WRITE =>

      we_intl <= '1';
      result_shift_en <= '1';

      if img_shift_in_cntr = IMG_BUF_WIDTH then
        next_acc_state <= ACC_SHIFT_UP;
        next_img_shift_up_cntr  <= img_shift_up_cntr + 1;
      else
        next_img_shift_in_cntr <= img_shift_in_cntr + 1;
        next_write_ptr <= write_ptr + 1;
      end if;

      if img_shift_up_cntr = IMG_HIGHT then
        next_acc_state <= ACC_IDLE;
        finish <= '1';
      end if;

    when others =>
    null;
  end case;

end process inv_state_logic;

end rtl;
