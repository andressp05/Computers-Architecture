--------------------------------------------------------------------------------
-- Unidad de control principal del PipeLine. Arq0 2017
--
-- Aitor Arnaiz del Val
-- Andres Salas Penia
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic;  -- 0=Reg. destino es rt, 1=rd
		-- Senial para el Jump
		Jump : out std_logic
   );
end control_unit;

architecture rtl of control_unit is

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
	constant OP_JUMP   : t_opCode := "000010";
	constant OP_ADDI   : t_opCode := "001000";
	constant OP_SLTI	 : t_opCode := "001010";

begin
	-- Asignacion a las salidas en funcion del tipo de operacion
	Branch <= '1' when OPCode = OP_BEQ  else '0';
	MemToReg <= '1' when OPCode = OP_LW else '0';
	MemWrite <= '1' when OPCode = OP_SW else '0';
	MemRead <= '1' when OPCode = OP_LW else '0';
	ALUSrc <= '1' when OPCode = OP_LW or OPCode = OP_SW or OPCode = OP_LUI or OPCode = OP_ADDI 
					or OPCode = OP_SLTI else '0';
	ALUOp <= "000" when OPCode = OP_LW or OPCode = OP_SW else
				"001" when OPCode = OP_BEQ else
				"010" when OPCode = OP_RTYPE else 
				"011" when OPCode = OP_LUI else 
				"100" when OPCode = OP_ADDI else "101";
	RegWrite <= '1' when OPCode = OP_RTYPE or OPCode = OP_LW or OPCode = OP_LUI or OPCode = OP_ADDI else '0';
	RegDst <= '1' when OPCode = OP_RTYPE else '0';
	Jump <= '1' when OPCode = OP_JUMP else '0';
end architecture;
