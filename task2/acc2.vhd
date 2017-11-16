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
  constant IMG_WIDTH          : integer := 352 - 1;

  constant IMG_BUF_DEPTH      : integer := 3 - 1;
  constant IMG_BUF_WIDTH      : integer := ((IMG_WIDTH + 1) / 4); -- 4 pixels (bytes pr word)
  -- constant IMG_BIT_COL_WIDH   : integer := (IMG_WIDTH * 8) - 1; -- 8 bits per pixel (byte)

  constant RAM_BLOCK_SIZE : integer := 50688 - 1;
  constant WRITE_BLOCK_START_ADDR : halfword_t := x"6300";


-- All internal signals are defined here
type inv_states is (ACC_IDLE, ACC_INIT, ACC_CALC, ACC_INIT_SHIFT_IN, ACC_INIT_SHIFT_UP, ACC_SHIFT_IN, ACC_SHIFT_UP, ACC_WRITE, ACC_WAIT);
type img_byte_arr_t is array (IMG_WIDTH downto 0) of byte_t;
type img_word_t_byte_arr_t is array (0 to 3) of byte_t;
type img_calc_buf_t is array (0 to IMG_BUF_DEPTH) of img_byte_arr_t;

signal acc_state : inv_states  := ACC_IDLE;
signal next_acc_state : inv_states  := ACC_IDLE;

signal write_ptr        : halfword_t := WRITE_BLOCK_START_ADDR;
signal next_write_ptr   : halfword_t := WRITE_BLOCK_START_ADDR;

signal read_ptr         : halfword_t := (others => '0');
signal next_read_ptr    : halfword_t := (others => '0');

signal img_result_reg : img_byte_arr_t := (others => (others => '0'));
signal img_calc_buf   : img_calc_buf_t := (others => (others => (others => '0')));

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

signal img_result_word : word_t := (others => '0'); --downto IMG_WIDTH - 4);

function wort_t_to_byte_arr (slv : in word_t) return img_word_t_byte_arr_t is
    variable result : img_word_t_byte_arr_t;
begin
    for i in 0 to 4 loop
        result(i) := slv(8*i+7 downto i);
    end loop;
    return result;
end function;


begin

 img_result_word <= img_result_reg(IMG_WIDTH - 0) &
                    img_result_reg(IMG_WIDTH - 1) &
                    img_result_reg(IMG_WIDTH - 2) &
                    img_result_reg(IMG_WIDTH - 3);




shift_in : process(clk)
begin
  if rising_edge(clk) then
    if img_shift_in_en = '1' then
      img_calc_buf(0) <= img_calc_buf(0)(IMG_WIDTH - 4 downto 0) & pixel_in(31 downto 24) & pixel_in(23 downto 16) & pixel_in(15 downto 8) & pixel_in(7 downto 0);
    end if;
  end if;
end process;


-- img_calc_buf(0) <=  pixel_in(31 downto 24)  &
--                     pixel_in(23 downto 16)  &
--                     pixel_in(15 downto 8)   &
--                     pixel_in(7 downto 0)    &
--                     img_calc_buf(0)(0 to IMG_WIDTH - 4);

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
-- variable Dx : signed(7 downto 0) := (others => '0');
-- variable Dy : signed(7 downto 0) := (others => '0');
--variable Dx : byte_t := (others => '0');
--variable Dy : byte_t := (others => '0');

variable Dx : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
variable Dy : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
variable mr1 : byte_t := (others => '0');
variable mr2 : byte_t := (others => '0');
variable mr3 : byte_t := (others => '0');
-- constant upper1 : signed( 7 downto 0) := (-1);
-- constant upper2 : signed( 7 downto 0) := (-2);
-- constant upper3 : signed( 7 downto 0) := (-1);
--
-- constant upper4 : signed( 7 downto 0) := (-1);
-- constant upper5 : signed( 7 downto 0) := (-2);
-- constant upper6 : signed( 7 downto 0) := (-1);

begin
  if rising_edge(clk) then
    if calc_en = '1' then

      calcLoop : for i in 1 to IMG_WIDTH - 1 loop

        mr1 := img_calc_buf(2)(i + 1) - img_calc_buf(2)(i - 1);
        mr2 := img_calc_buf(1)(i + 1) - img_calc_buf(1)(i - 1);
        mr3 := img_calc_buf(0)(i + 1) - img_calc_buf(0)(i - 1);

        Dx := mr1 + (mr2(6 downto 0) & '0') + mr3;

        (img_calc_buf(2)(i - 1)) -
        (img_calc_buf(2)(i)(6 downto 0) & '0') -
        (img_calc_buf(2)(i + 1)) 
        ;
        img_result_reg(i) <= byte_t( STD_LOGIC_VECTOR(abs(signed(Dx)) + abs(signed(Dy)))(10 downto 3));--+ Dy;
        --img_result_reg(i) <= byte_t( (abs(signed(Dx) + abs(signed(Dy)))));--+ Dy;

        -- img_result_reg(i) <= byte_t(abs(signed(Dy)));

      end loop;


      -- img_result_reg <= img_calc_buf(1);
    elsif result_shift_en = '1' then
      img_result_reg <= img_result_reg(IMG_WIDTH - 4 downto 0) & x"00" & x"00" & x"00" & x"00";
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
  calc_en <= '0';

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
        img_shift_in_en <= '1';
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
