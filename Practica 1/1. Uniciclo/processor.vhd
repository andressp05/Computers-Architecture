--------------------------------------------------------------------------------
-- Procesador MIPS uniciclo curso Arquitectura 2017-18
--
-- Aitor Arnaiz del Val
-- Andres Salas Penia
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura PAQUESEUSA?
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 

signal PC: std_logic_vector (31 downto 0);
signal PC_add4: std_logic_vector (31 downto 0);
signal ALUResult: std_logic_vector (31 downto 0);
signal SignExtend: std_logic_vector (31 downto 0);
signal MuxIMtoReg: std_logic_vector (4 downto 0);

signal MuxRegtoAlu: std_logic_vector (31 downto 0);
signal MuxAluResulttoPC: std_logic_vector (31 downto 0);
signal MuxDMtoReg: std_logic_vector (31 downto 0);
signal MuxMuxAluResulttoPCtoJUMP: std_logic_vector (31 downto 0);

-- Signals of Registers
signal Rd1: std_logic_vector(31 downto 0);
signal Rd2: std_logic_vector(31 downto 0);

-- Signals of ALU
signal ZFlag: std_logic;
signal Result: std_logic_vector(31 downto 0);

-- Signals of Control Unit
signal MemRead: std_logic;
signal MemToReg: std_logic;
signal MemWrite: std_logic;
signal RegWrite: std_logic;
signal RegDst:  std_logic;
signal ALUSrc: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);
signal Branch: std_logic;
signal Jump: std_logic;

-- Signal of ALU Control
signal ALUControl: std_logic_vector (3 downto 0);

signal sIDataIn: std_logic_vector(31 downto 0);

component alu port(
		OpA     : in  std_logic_vector (31 downto 0); -- Operando A
      OpB     : in  std_logic_vector (31 downto 0); -- Operando B
      Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
      Result  : out std_logic_vector (31 downto 0); -- Resultado
      ZFlag   : out std_logic                       -- Flag Z 
	);
end component;

component alu_control port(
		-- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
	);
end component;

component reg_bank port(
		Clk   : in std_logic; -- Reloj activo en flanco de subida
      Reset : in std_logic; -- Reset asíncrono a nivel alto
      A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
      Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
      A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
      Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
      A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
      Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
      We3   : in std_logic -- Habilitación de la escritura de Wd3
		);
end component;
	
component control_unit port(
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
		Jump     : out std_logic
   );
end component;

begin

--Port Maps de los componentes
IAlu: alu port map 
		(OpA => Rd1, OpB => MuxRegtoAlu, Control => ALUControl, Result => Result, ZFlag => ZFlag);

IAlu_Control: alu_control port map
		(ALUOp => ALUOp, Funct => sIDataIn (5 downto 0), ALUControl => ALUControl);

IReg_Bank: reg_bank port map
		(Clk => Clk, Reset => Reset, A1 => sIDataIn (25 downto 21), Rd1 => Rd1,
		A2 => sIDataIn (20 downto 16), Rd2 => Rd2, A3=>MuxIMtoReg,
		 Wd3 => MuxDMtoReg, We3 => RegWrite);
		
IControl_Unit: control_unit port map
		(OpCode => sIDataIn(31 downto 26), Branch => Branch, MemToReg => MemToReg, MemWrite => MemWrite, MemRead => MemRead,
		 ALUSrc => ALUSrc, ALUOp => ALUOp, RegWrite => RegWrite, RegDst => RegDst, Jump => Jump);

-- Conexion componentes
sIDataIn <= IDataIn;
SignExtend(31 downto 16) <= (others => sIDataIn(15));
SignExtend(15 downto 0) <= sIDataIn(15 downto 0); 

IAddr <= PC;
PC_add4 <= PC + 4;
ALUResult <= PC_add4 + (SignExtend(29 downto 0) & "00");

DWrEn <= MemWrite;
DRdEn <= MemRead;

DAddr <= Result;
DDataOut <= Rd2;

--Conexion multiplexores
MuxIMtoReg <= sIDataIn(20 downto 16) when RegDst = '0' else sIDataIn(15 downto 11);
MuxRegtoAlu <= Rd2 when ALUSrc = '0' else SignExtend;
MuxAluResulttoPC <=  ALUResult when (Branch and ZFlag) = '1' else PC_add4;
MuxDMtoReg <= Result when MemToReg = '0' else DDataIn;
MuxMuxAluResulttoPCtoJUMP <= (PC_add4 (31 downto 28) & sIDataIn (25 downto 0) & "00") when Jump = '1' else MuxAluResulttoPC;


--Proceso para el reset asíncrono
process(Reset,Clk)
begin
   if Reset='1' then
		PC <= X"00000000";
   elsif rising_edge(Clk) then
      PC <= MuxMuxAluResulttoPCtoJUMP;
   end if;
end process;

end architecture;
