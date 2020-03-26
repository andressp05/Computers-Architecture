--------------------------------------------------------------------------------
-- Procesador Pipeline curso Arquitectura 2017-18
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

-- ProgramCounter
signal PC: std_logic_vector (31 downto 0);

-- Multiplexores
signal MuxRegtoAlu: std_logic_vector (31 downto 0);
signal MuxAluResulttoPC: std_logic_vector (31 downto 0);
signal MuxDMtoReg_ID: std_logic_vector (31 downto 0);
signal MuxDMtoReg_WB: std_logic_vector (31 downto 0);
signal MuxMuxAluResulttoPCtoJUMP: std_logic_vector (31 downto 0);
signal MuxIMtoReg_EX: std_logic_vector (4 downto 0);
signal MuxIMtoReg_MEM: std_logic_vector (4 downto 0);
signal MuxIMtoReg_WB: std_logic_vector (4 downto 0);


-- Signals in IF
signal Instr_IF: std_logic_vector (31 downto 0);
signal PCSrc_IF: std_logic; 
signal ALUResult_IF: std_logic_vector (31 downto 0);
signal PC_add4_IF: std_logic_vector (31 downto 0);

-- Signals in ID
signal Instr_ID: std_logic_vector (31 downto 0);
signal We3_ID: std_logic;
signal SignExtend_ID: std_logic_vector (31 downto 0);
signal PC_add4_ID: std_logic_vector (31 downto 0);
signal Reg3toMux_ID: std_logic_vector(4 downto 0);

-- Signals in EX
signal ZFlag_EX: std_logic;
signal ALUResult_EX: std_logic_vector (31 downto 0);
signal SignExtend_EX: std_logic_vector (31 downto 0);
signal Result_EX: std_logic_vector(31 downto 0);
signal PC_add4_EX: std_logic_vector (31 downto 0);
signal Reg3toMux_EX: std_logic_vector(4 downto 0);

-- Signals in MEM
signal PCSrc_MEM: std_logic;
signal ZFlag_MEM: std_logic;
signal ALUResult_MEM: std_logic_vector (31 downto 0);
signal Result_MEM: std_logic_vector(31 downto 0);
signal DDataIn_MEM: std_logic_vector(31 downto 0);

-- Signals in WB
signal Result_WB: std_logic_vector(31 downto 0);
signal DDataIn_WB: std_logic_vector(31 downto 0);

-- Signal of ALU Control
signal ALUControl: std_logic_vector (3 downto 0);

-- Signals of Registers
-- Signals in ID
signal A1_ID: std_logic_vector(4 downto 0);
signal A2_ID: std_logic_vector(4 downto 0);
signal A3_ID: std_logic_vector (4 downto 0);
signal Rd1_ID: std_logic_vector(31 downto 0);
signal Rd2_ID: std_logic_vector(31 downto 0);
-- Signals in EX
signal A2_EX: std_logic_vector(4 downto 0);
signal Rd1_EX: std_logic_vector(31 downto 0);
signal Rd2_EX: std_logic_vector(31 downto 0);
--Signals in MEM
signal Rd2_MEM: std_logic_vector(31 downto 0);


-- Signals of Control Unit
-- Signals in IF
signal Jump_IF: std_logic;
-- Signals in ID
signal MemRead_ID: std_logic;
signal MemToReg_ID: std_logic;
signal MemWrite_ID: std_logic;
signal RegWrite_ID: std_logic;
signal RegDst_ID:  std_logic;
signal ALUSrc_ID: std_logic;
signal ALUOp_ID: std_logic_vector(2 downto 0);
signal Branch_ID: std_logic;
signal Jump_ID: std_logic;
-- Signals in EX
signal MemRead_EX: std_logic;
signal MemToReg_EX: std_logic;
signal MemWrite_EX: std_logic;
signal RegWrite_EX: std_logic;
signal RegDst_EX:  std_logic;
signal ALUSrc_EX: std_logic;
signal ALUOp_EX: std_logic_vector(2 downto 0);
signal Branch_EX: std_logic;
signal Jump_EX: std_logic;
-- Signals in MEM
signal MemRead_MEM: std_logic;
signal MemToReg_MEM: std_logic;
signal MemWrite_MEM: std_logic;
signal RegWrite_MEM: std_logic;
signal Branch_MEM: std_logic;
-- Signals in WB
signal MemToReg_WB: std_logic;
signal RegWrite_WB: std_logic;

-- Componentes a instanciar
-- ALU
component alu port(
		OpA     : in  std_logic_vector (31 downto 0); -- Operando A
      OpB     : in  std_logic_vector (31 downto 0); -- Operando B
      Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
      Result  : out std_logic_vector (31 downto 0); -- Resultado
      ZFlag   : out std_logic                       -- Flag Z 
	);
end component;
-- ALU Control
component alu_control port(
		-- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
	);
end component;
-- Banco de Registros
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
-- Unidad de Control
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
-- Etapa IF
Instr_IF <= IDataIn;
IAddr <= PC;
PC_add4_IF <= PC + 4;

MuxAluResulttoPC <=  ALUResult_IF when (PCSrc_IF) = '1' else PC_add4_IF;
MuxMuxAluResulttoPCtoJUMP <= (PC_add4_IF (31 downto 28) & Instr_IF (25 downto 0) & "00") when Jump_IF = '1' else MuxAluResulttoPC;

--Proceso para el reset asíncrono
PC_count: process(Reset,Clk)
begin
	-- Reseteamos todos los valores
   if Reset='1' then
		PC <= X"00000000";
   elsif rising_edge(Clk) then
      PC <= MuxMuxAluResulttoPCtoJUMP;
   end if;
end process;



-- Etapa ID
IReg_Bank: reg_bank port map
		(Clk => Clk, Reset => Reset, A1 => A1_ID, Rd1 => Rd1_ID,
		A2 => A2_ID, Rd2 => Rd2_ID, A3=> A3_ID,
		 Wd3 => MuxDMtoReg_ID, We3 => We3_ID);
		 
IControl_Unit: control_unit port map
		(OpCode => Instr_ID(31 downto 26), Branch => Branch_ID, MemToReg => MemToReg_ID, MemWrite => MemWrite_ID, MemRead => MemRead_ID,
		 ALUSrc => ALUSrc_ID, ALUOp => ALUOp_ID, RegWrite => RegWrite_ID, RegDst => RegDst_ID, Jump => Jump_ID);

SignExtend_ID(31 downto 16) <= (others => Instr_ID(15));
SignExtend_ID(15 downto 0) <= Instr_ID(15 downto 0);

A1_ID <= Instr_ID(25 downto 21);
A2_ID <= Instr_ID(20 downto 16);
Reg3toMux_ID <= Instr_ID(15 downto 11);

-- Proceso Etapa ID
reg_IF_ID: process(Reset, Clk)
begin
	-- Reseteamos todos los valores
	if Reset = '1' then
		Instr_ID <= X"00000000";
		PC_add4_ID <= X"00000000";
	elsif rising_edge(Clk) then
		Instr_ID <= Instr_IF;
		PC_add4_ID <= PC_add4_IF;
	end if;
end process;


-- Etapa EX
IAlu: alu port map 
		(OpA => Rd1_EX, OpB => MuxRegtoAlu, Control => ALUControl, Result => Result_EX, ZFlag => ZFlag_EX);

IAlu_Control: alu_control port map
		(ALUOp => ALUOp_EX, Funct => SignExtend_EX (5 downto 0), ALUControl => ALUControl);

MuxRegtoAlu <= Rd2_EX when ALUSrc_EX = '0' else SignExtend_EX;
MuxIMtoReg_EX <= A2_EX when RegDst_EX = '0' else Reg3toMux_EX;

ALUResult_EX <= PC_add4_EX + (SignExtend_EX(29 downto 0) & "00");
Jump_IF <= Jump_EX;

-- Proceso Etapa EX
reg_ID_EX: process(Reset, Clk)
begin
	-- Reseteamos todos los valores
	if Reset = '1' then
		Branch_EX <= '0';
		MemToReg_EX <= '0';
		MemWrite_EX <= '0';
		MemRead_EX <= '0';
		ALUSrc_EX <= '0';
		ALUOp_EX <= "000";
		RegWrite_EX <= '0';
		RegDst_EX <= '0';
		Jump_EX <= '0';
		PC_add4_EX <= X"00000000";
		Rd1_EX <= X"00000000";
		Rd2_EX <= X"00000000";
		SignExtend_EX <= X"00000000";
		A2_EX <= "00000";
		Reg3toMux_EX <= "00000";
		
	elsif rising_edge(Clk) then
		Branch_EX <= Branch_ID;
		MemToReg_EX <= MemToReg_ID;
		MemWrite_EX <= MemWrite_ID;
		MemRead_EX <= MemRead_ID;
		ALUSrc_EX <= ALUSrc_ID;
		ALUOp_EX <= ALUOp_ID;
		RegWrite_EX <= RegWrite_ID;
		RegDst_EX <= RegDst_ID;
		Jump_EX <= Jump_ID;
		PC_add4_EX <= PC_add4_ID;
		Rd1_EX <= Rd1_ID;
		Rd2_EX <= Rd2_ID;
		SignExtend_EX <= SignExtend_ID;
		A2_EX <= A2_ID;
		Reg3toMux_EX <= Reg3toMux_ID;
	end if;
end process;


--Etapa MEM


DAddr <= Result_MEM;
DDataOut <= Rd2_MEM;
DDataIn_MEM <= DDataIn;
DWrEn <= MemWrite_MEM;
DRdEn <= MemRead_MEM;

ALUResult_IF <= ALUResult_MEM;
PCSrc_MEM <= ZFlag_MEM and Branch_MEM; 
PCSrc_IF <= PCSrc_MEM;

-- Proceso Etapa MEM
reg_EX_MEM: process(Reset, Clk)
begin
	-- Reseteamos todos los valores
	if Reset = '1' then
		Branch_MEM <= '0';
		MemToReg_MEM <= '0';
		MemWrite_MEM <= '0';
		MemRead_MEM <= '0';
		RegWrite_MEM <= '0';
		ALUResult_MEM <= X"00000000";
		ZFlag_MEM <= '0';
		Result_MEM <= X"00000000";
		Rd2_MEM <= X"00000000";
		MuxIMtoReg_MEM <= "00000";
		
	elsif rising_edge(Clk) then
		Branch_MEM <= Branch_EX;
		MemToReg_MEM <= MemToReg_EX;
		MemWrite_MEM <= MemWrite_EX;
		MemRead_MEM <= MemRead_EX;
		RegWrite_MEM <= RegWrite_EX;
		ALUResult_MEM <= ALUResult_EX;
		ZFlag_MEM <= ZFlag_EX;
		Result_MEM <= Result_EX;
		Rd2_MEM <= Rd2_EX;
		MuxIMtoReg_MEM <= MuxIMtoReg_EX;
	end if;
end process;

-- Etapa WB
MuxDMtoReg_WB <= Result_WB when MemToReg_WB = '0' else DDataIn_WB;
MuxDMtoReg_ID <= MuxDMtoReg_WB;
A3_ID <= MuxIMtoReg_WB;
We3_ID <= RegWrite_WB;

-- Proceso Etapa WB
reg_MEM_WB: process (Reset, Clk)
begin
	-- Reseteamos todos los valores
	if Reset = '1' then
		MemToReg_WB <= '0';
		RegWrite_WB <= '0';
		DDataIn_WB <= X"00000000";
		Result_WB <= X"00000000";
		MuxIMtoReg_WB <= "00000";
	
	elsif rising_edge(Clk) then
		MemToReg_WB <= MemToReg_MEM;
		RegWrite_WB <= RegWrite_MEM;
		DDataIn_WB <= DDataIn_MEM;
		Result_WB <= Result_MEM;
		MuxIMtoReg_WB <= MuxIMtoReg_MEM;
	end if;
end process;
end architecture;
