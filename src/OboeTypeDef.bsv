package OboeTypeDef;

import OboeConfig::*;

/////////////////////////////////////
// Section: RISC-V ISA Definitions //
/////////////////////////////////////

// Typedef: XLEN
//   RISC-V XLEN.
typedef 32 XLEN;

// Typedef: NumArchRegs
//   Number of architectural registers.
typedef 32 NumArchRegs;

// Constant: kNumArchRegs
//   Integer value of <NumArchRegs>.
Integer kNumArchRegs = valueOf(NumArchRegs);

// Typedef: ArchRegId
//   Architectural register ID/specifier type.
typedef UInt#(TLog#(NumArchRegs)) ArchRegId;

typedef Bit#(7) Opcode;

Opcode opcode_op_imm = 'b0010011;
Opcode opcode_op     = 'b0110011;
Opcode opcode_lui    = 'b0110111;
Opcode opcode_auipc  = 'b0010111;
Opcode opcode_jal    = 'b1101111;
Opcode opcode_jalr   = 'b1100111;
Opcode opcode_branch = 'b1100011;
Opcode opcode_load   = 'b0000011;
Opcode opcode_store  = 'b0100011;
Opcode opcode_system = 'b1110011;

typedef Bit#(3) Funct3;

Funct3 funct3_add  = 'b000;
Funct3 funct3_sll  = 'b001;
Funct3 funct3_slt  = 'b010;
Funct3 funct3_sltu = 'b011;
Funct3 funct3_xor  = 'b100;
Funct3 funct3_srl  = 'b101;
Funct3 funct3_or   = 'b110;
Funct3 funct3_and  = 'b111;

Funct3 funct3_lb   = 'b000;
Funct3 funct3_lh   = 'b001;
Funct3 funct3_lw   = 'b010;
Funct3 funct3_lbu  = 'b100;
Funct3 funct3_lhu  = 'b101;

Funct3 funct3_sb   = 'b000;
Funct3 funct3_sh   = 'b001;
Funct3 funct3_sw   = 'b010;

Funct3 funct3_beq  = 'b000;
Funct3 funct3_bne  = 'b001;
Funct3 funct3_blt  = 'b100;
Funct3 funct3_bge  = 'b101;
Funct3 funct3_bltu = 'b110;
Funct3 funct3_bgeu = 'b111;

Funct3 funct3_csrrw  = 'b001;
Funct3 funct3_csrrs  = 'b010;
Funct3 funct3_csrrc  = 'b011;
Funct3 funct3_csrrwi = 'b101;
Funct3 funct3_csrrsi = 'b110;
Funct3 funct3_csrrci = 'b111;
Funct3 funct3_priv   = 'b000;

typedef Bit#(7) Funct7;

typedef Bit#(12) Funct12;

Funct12 funct12_mret = 'b0011_0000_0010;  // trap return
Funct12 funct12_wfi  = 'b0001_0000_0101;  // interrupt management

// Typedef: RType
//   R-type instruction format.
typedef struct {
  Funct7    funct7;
  ArchRegId rs2;
  ArchRegId rs1;
  Funct3    funct3;
  ArchRegId rd;
  Opcode    opcode;
} RType deriving(Eq, Bits);

// Typedef: IType
//   I-type instruction format.
typedef struct {
  Bit#(12)  imm;
  ArchRegId rs1;
  Funct3    funct3;
  ArchRegId rd;
  Opcode    opcode;
} IType deriving(Eq, Bits);

// Typedef: SType
//   S-type instruction format.
typedef struct {
  Bit#(7)   imm2;
  ArchRegId rs2;
  ArchRegId rs1;
  Funct3    funct3;
  Bit#(5)   imm1;
  Opcode    opcode;
} SType deriving(Eq, Bits);

// Typedef: BType
//   B-type instruction format.
typedef struct {
  Bit#(1)   imm4;
  Bit#(6)   imm2;
  ArchRegId rs2;
  ArchRegId rs1;
  Funct3    funct3;
  Bit#(4)   imm1;
  Bit#(1)   imm3;
  Opcode    opcode;
} BType deriving(Eq, Bits);

// Typedef: UType
//   U-type instruction format.
typedef struct {
  Bit#(20)  imm;
  ArchRegId rd;
  Opcode    opcode;
} UType deriving(Eq, Bits);

// Typedef: JType
//   J-type instruction format.
typedef struct {
  Bit#(1)   imm4;
  Bit#(10)  imm1;
  Bit#(1)   imm2;
  Bit#(8)   imm3;
  ArchRegId rd;
  Opcode    opcode;
} JType deriving(Eq, Bits);

// Typedef: TrapCause
//   Define the trap type and cause
typedef struct {
  Bool     isInterrupt;
  Bit#(31) code;
} TrapCause deriving(Bits, FShow);

/////////////////////////////////////////////////
// Section: Microarchitecture type definitions //
/////////////////////////////////////////////////

// Typedef: TagWidth
//   Bit width of <Tag>.
typedef TLog#(NumPhysicalRegs) TagWidth;

// Typedef: Tag
//   Pointer to the physical register or ROB, used for renaming.
typedef UInt#(TagWidth) Tag;

// Typedef: Word
//   XLEN-width bit data.
typedef Bit#(XLEN) Word;

// Typdef: CsrId
//   Identifier of CSR
typedef UInt#(12) CsrId;

// Typedef: RawInst
//   XLEN-width raw RISC-V instruction.
typedef Bit#(XLEN) RawInst;

// Enum: AluOp
//   Enumerate operation that could done by ALU.
typedef enum {
  ADD, SUB,
  SLL, SRL, SRA,
  AND, OR, XOR,
  LT, LTU
} AluOp deriving(Bits, Eq, FShow);

// Enum: AluSrc
//   Enumerate type of different type of operand combination that uses ALU.
//
//   Rs1Rs2 - Operation between two registers.
//   Rs1Imm - Operation between register and immediate value.
//   PcImm  - Operation between PC and immediate value.
//   Pc4    - Operation between PC and immediate value 4.
typedef enum {
  Rs1Imm, PcImm, Rs1Rs2,
  Pc4  // PC + 4
} AluSrc deriving(Bits, Eq, FShow);

// Typedef: AluCtrl
//   Structure that combines the source operand type and ALU opcode
typedef struct {
  AluOp  op;
  AluSrc src;
} AluCtrl deriving(Bits, Eq, FShow);

// Enum: BruOp
//   Enumerate operation that could done by BRU.
typedef enum {
  JAL,
  EQ, NE,
  LT, LTU,
  GE, GEU
} BruOp deriving(Bits, Eq, FShow);

// Enum: BruSrc
//   Enumerate type of different type of operand combination that uses BRU.
//
//   PcImm  - Operation between PC and immediate value.
//   Rs1Imm - Operation between register and immediate value.
typedef enum {
  PcImm,
  Rs1Imm
} BruSrc deriving(Bits, Eq, FShow);

// Typedef: BruCtrl
//   Structure that combines the source operand type and BRU opcode
typedef struct {
  BruOp  op;
  BruSrc src;
} BruCtrl deriving(Bits, Eq, FShow);

// Enum: CsruOp
//   Enumerate operation that could done by CSRU.
//
//   RW - read-write
//   RS - read-set
//   RC - read-clear
typedef enum {
  RW,
  RS,
  RC
} CsruOp deriving(Bits, Eq, FShow);

// Enum: CsruSrc
//   Enumerate type of different type of source operand that uses CSRU.
//
//   Rs1  - Operation based on RS1 register.
//   Uimm - Operation based immediate value.
typedef enum {
  Rs1, Uimm
} CsruSrc deriving(Bits, Eq, FShow);

// Typedef: CsruCtrl
//   Structure that combines the source operand type and CSRU opcode
typedef struct {
  CsruOp  op;
  CsruSrc src;
} CsruCtrl deriving(Bits, Eq, FShow);

// Enum: LsuOp
//   Enumerate operation that could done by LSU.
typedef enum {
  LW, LH, LB, LHU, LBU,
  SW, SH, SB
} LsuOp deriving(Bits, Eq, FShow);

// Enum: LsuSrc
//
//   Rs1Imm    - Operation between register and immediate value.
//   Rs1Rs2Imm - Operation between two registers and immediate value.
typedef enum {
  Rs1Imm, Rs1Rs2Imm
} LsuSrc deriving(Bits, Eq, FShow);

// Typedef: LsuCtrl
//   Structure that combines the source operand type and LSU opcode
typedef struct {
  LsuOp  op;
  LsuSrc src;
} LsuCtrl deriving(Bits, Eq, FShow);

// Typedef: FunctionUnit
//   Union tagged structure. Responsible compute unit for a instruction.
typedef union tagged {
  void     Invalid;
  AluCtrl  ALU;
  BruCtrl  BRU;
  CsruCtrl CSRU;
  LsuCtrl  LSU;
} FunctionUnit deriving(Bits, Eq, FShow);

// Typedef: BackendInst
//   Structure for decoded instruction.
typedef struct {
  Word              pc;
  ArchRegId         rs1;
  ArchRegId         rs2;
  ArchRegId         rd;
  Word              imm;
  FunctionUnit      fu;
  Maybe#(TrapCause) trap;
} BackendInst deriving(Bits, FShow);

endpackage
