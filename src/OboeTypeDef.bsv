package OboeTypeDef;

import OboeConfig::*;

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
typedef Bit#(12) CsrId;


// Section: Decoder type definitions

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

// Typedef: TrapCause
//   Define the trap type and cause
typedef struct {
  Bool isInterrupt;
  Bit#(31) code;
} TrapCause deriving(Bits, FShow);

// Typedef: BackendInst
//   Structure for decoded instruction.
typedef struct {
  Word              pc;
  ArchRegId         rs1;
  ArchRegId         rs2;
  ArchRegId         rd;
  Word              imm;
  FunctionUnit      fu;
  CsrId             csr;
  Maybe#(TrapCause) trap;
} BackendInst deriving(Bits, FShow);

endpackage
