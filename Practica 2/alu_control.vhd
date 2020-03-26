--------------------------------------------------------------------------------
-- Bloque de control para la ALU del PipeLine. Arq0 2017.
--
-- Aitor Arnaiz del Val
-- Andres Salas Penia
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is
   
	 -- Tipo para los codigos de operacion:
   subtype t_aluOp is std_logic_vector (2 downto 0);
	
	-- Tipo para los codigos de control de la ALU:
   subtype t_funct is std_logic_vector (3 downto 0);

	--Tipo para los codigos de funct de entrada--
	subtype in_funct is std_logic_vector (5 downto 0);
	
	-- Codigos de control:
	constant ALU_MEM    : t_aluOp := "000";   
   constant ALU_BEQ    : t_aluOp := "001";
	constant ALU_RTYPE  : t_aluOp := "010";
	constant ALU_LUI    : t_aluOp := "011";
	constant ALU_ADDI   : t_aluOp := "100";
	constant ALU_SLTI	  : t_aluOp := "101";
	
	-- Codigos de control de ALUOp:
   constant FUNCT_OR   : t_funct := "0111";   
   constant FUNCT_XOR  : t_funct := "0110";
   constant FUNCT_AND  : t_funct := "0100";
   constant FUNCT_SUB  : t_funct := "0001";
   constant FUNCT_ADD  : t_funct := "0000"; 
	constant FUNCT_SLT  : t_funct := "1010";
	constant FUNCT_SL16 : t_funct := "1101"; -- Para Lui
	
	
	
	--Codigos funct entrada (shamt)--
	constant IN_FUNCT_OR    : in_funct :=  "100101";
	constant IN_FUNCT_XOR   : in_funct :=  "100110";
	constant IN_FUNCT_AND   : in_funct :=  "100100";
	constant IN_FUNCT_SUB   : in_funct :=  "100010";
	constant IN_FUNCT_ADD   : in_funct :=  "100000";
	constant IN_FUNCT_SLT  : in_funct :=  "101010";
	
	
	
begin
	-- Asignacion de la operacion a realizar a la ALU
	ALUControl <= FUNCT_OR when ALUOp = ALU_RTYPE and Funct = IN_FUNCT_OR else
					  FUNCT_ADD when ALUOp = ALU_RTYPE and Funct = IN_FUNCT_ADD else
	              FUNCT_XOR when ALUOp = ALU_RTYPE and Funct = IN_FUNCT_XOR else
	              FUNCT_AND when ALUOp = ALU_RTYPE and Funct = IN_FUNCT_AND else
	              FUNCT_SUB when ALUOp = ALU_RTYPE and Funct = IN_FUNCT_SUB else
	              FUNCT_SLT when  ALUOp = ALU_RTYPE and Funct = IN_FUNCT_SLT else
					  FUNCT_ADD when ALUOp = ALU_MEM else
					  FUNCT_SL16 when ALUOp = ALU_LUI else
					  FUNCT_SUB when ALUOp = ALU_BEQ else
					  FUNCT_ADD when ALUOp = ALU_ADDI else
					  FUNCT_SLT;
end architecture;