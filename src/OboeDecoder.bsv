package OboeDecoder;
import OboeTypeDef::*;

// Typedef: RType
//   R-type instruction format.
typedef struct {
  Bit#(7) funct7;
  ArchRegId rs2;
  ArchRegId rs1;
  Bit#(3) funct3;
  ArchRegId rd;
  Bit#(7) opcode;
} RType deriving(Eq, Bits);

// Typedef: IType
//   I-type instruction format.
typedef struct {
  Bit#(12) imm;
  ArchRegId rs1;
  Bit#(3) funct3;
  ArchRegId rd;
  Bit#(7) opcode;
} IType deriving(Eq, Bits);

// Typedef: SType
//   S-type instruction format.
typedef struct {
  Bit#(7) imm2;
  ArchRegId rs2;
  ArchRegId rs1;
  Bit#(3) funct3;
  Bit#(5) imm1;
  Bit#(7) opcode;
} SType deriving(Eq, Bits);

// Typedef: UType
//   U-type instruction format.
typedef struct {
  Bit#(20) imm;
  ArchRegId rd;
  Bit#(7) opcode;
} UType deriving(Eq, Bits);

// Typedef: OpCodeWidth
typedef 7 OpCodeWidth;

Bit#(OpCodeWidth) op_imm    = 'b0010011;
Bit#(OpCodeWidth) op_r      = 'b0110011;
Bit#(OpCodeWidth) op_lui    = 'b0110111;
Bit#(OpCodeWidth) op_auipc  = 'b0010111;
Bit#(OpCodeWidth) op_jal    = 'b1101111;
Bit#(OpCodeWidth) op_jalr   = 'b1100111;
Bit#(OpCodeWidth) op_branch = 'b1100011;
Bit#(OpCodeWidth) op_load   = 'b0000011;
Bit#(OpCodeWidth) op_store  = 'b0100011;
Bit#(OpCodeWidth) op_csr    = 'b1110011;

// Interface: OboeDecoder
interface OboeDecoder;
  // Method: decode
  //   Take the raw instruction and decode into backend-friendly structure.
  //
  // Parameter:
  //   inst - XLEN-bit raw instruction.
  //   pc   - Instruction program counter.
  //
  // Return:
  //   Backend-friendly structure <BackendInst>.
  method BackendInst decode(RawInst inst, Word pc);
endinterface

// Module: mkOboeDecoder
//   Decoder module for oboe.
module mkOboeDecoder(OboeDecoder);

  // Function: opImmDecode
  //   Decode the instructions with opcode = OP_IMM.
  function BackendInst opImmDecode(RawInst inst);
    IType decoded_inst = unpack(inst);

    BackendInst return_inst;
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};  // default value
    Word i_imm = signExtend(inst[31:20]);

    Bool isInvalid = False;  // to check the decoding procedure is valid or not
    case (decoded_inst.funct3)
      'b000: alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};
      'b100: alu_ctrl = AluCtrl {op: XOR, src: Rs1Imm};
      'b110: alu_ctrl = AluCtrl {op: OR, src: Rs1Imm};
      'b111: alu_ctrl = AluCtrl {op: AND, src: Rs1Imm};
      'b010: alu_ctrl = AluCtrl {op: LT, src: Rs1Imm};
      'b011: begin 
        i_imm = zeroExtend(decoded_inst.imm);
        alu_ctrl = AluCtrl {op: LTU, src: Rs1Imm}; 
      end
      'b001: begin 
        i_imm = zeroExtend(decoded_inst.imm[4:0]);
        alu_ctrl = AluCtrl {op: SLL, src: Rs1Imm};
      end
      'b101: begin 
        i_imm = zeroExtend(decoded_inst.imm[4:0]);
        if (inst[31:25] == 0)
          alu_ctrl = AluCtrl {op: SRL, src: Rs1Imm};
        else if (inst[31:25] == 'b0100000)
          alu_ctrl = AluCtrl {op: SRA, src: Rs1Imm};
        else
          isInvalid = True;
      end
      default:
        isInvalid = True;
    endcase

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: i_imm,
      csr: 0,
      fu: tagged ALU alu_ctrl,
      trap: (isInvalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opLuiDecode
  //   Decode the instructions with opcode = LUI.
  function BackendInst opLuiDecode(RawInst inst);
    UType decoded_inst = unpack(inst);

    BackendInst return_inst;
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};  // default value
    Word u_imm = {inst[31:12], 12'b0};

    return_inst = BackendInst {
      pc: ?,
      rs1: 0,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: u_imm,
      csr: 0,
      fu: tagged ALU alu_ctrl,
      trap: tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opAuipcDecode
  //   Decode the instructions with opcode = AUIPC.
  function BackendInst opAuipcDecode(RawInst inst);
    UType decoded_inst = unpack(inst);

    BackendInst return_inst;
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: PcImm};  // default value
    Word u_imm = {inst[31:12], 12'b0};

    return_inst = BackendInst {
      pc: ?,
      rs1: 0,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: u_imm,
      csr: 0,
      fu: tagged ALU alu_ctrl,
      trap: tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opRDecode
  //   Decode the instructions with opcode = OP.
  function BackendInst opRDecode(RawInst inst);
    RType decoded_inst = unpack(inst);

    BackendInst return_inst;
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Rs2};  // default value

    Bool isInvalid = False;
    if (decoded_inst.funct3 != 'b101 && decoded_inst.funct3 != 'b000) begin
      isInvalid = (decoded_inst.funct7 != 0);
    end

    case (decoded_inst.funct3)
      'b000: begin 
        if (decoded_inst.funct7 == 0)
          alu_ctrl = AluCtrl {op: ADD, src: Rs1Rs2};
        else if (decoded_inst.funct7 == 'b00100000)
          alu_ctrl = AluCtrl {op: SUB, src: Rs1Rs2};
        else isInvalid = True;
      end
      'b010: alu_ctrl = AluCtrl {op: LT, src: Rs1Rs2};
      'b011: alu_ctrl = AluCtrl {op: LTU, src: Rs1Rs2};
      'b111: alu_ctrl = AluCtrl {op: AND, src: Rs1Rs2};
      'b110: alu_ctrl = AluCtrl {op: OR, src: Rs1Rs2};
      'b100: alu_ctrl = AluCtrl {op: XOR, src: Rs1Rs2};
      'b001: alu_ctrl = AluCtrl {op: SLL, src: Rs1Rs2};
      'b101: begin 
        if (decoded_inst.funct7 == 0)
          alu_ctrl = AluCtrl {op: SRL, src: Rs1Rs2};
        else if (decoded_inst.funct7 == 'b00100000)
          alu_ctrl = AluCtrl {op: SRA, src: Rs1Rs2};
        else isInvalid = True;
      end
      default: isInvalid = True;
    endcase

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: decoded_inst.rs2,
      rd: decoded_inst.rd,
      imm: 0,
      csr: 0,
      fu: tagged ALU alu_ctrl,
      trap: (isInvalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
    };
    return return_inst;
  endfunction
  
  // Function: opJalDecode
  //   Decode the instructions with opcode = JAL.
  function BackendInst opJalDecode(RawInst inst);
    UType decoded_inst = unpack(inst);

    BackendInst return_inst;
    BruCtrl bru_ctrl = BruCtrl {op: JAL, src: PcImm};  // default value
    Word j_imm = signExtend({inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}); 

    return_inst = BackendInst {
      pc: ?,
      rs1: 0,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: j_imm,
      csr: 0,
      fu: tagged BRU bru_ctrl,
      trap: tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opJalrDecode
  //   Decode the instructions with opcode = JALR.
  function BackendInst opJalrDecode(RawInst inst);
    IType decoded_inst = unpack(inst);

    BackendInst return_inst;
    BruCtrl bru_ctrl = BruCtrl {op: JAL, src: Rs1Imm};  // default value
    Word i_imm = signExtend(inst[31:20]);

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: i_imm,
      csr: 0,
      fu: tagged BRU bru_ctrl,
      trap: tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opBranchDecode
  //   Decode the instructions with opcode = BRANCH.
  function BackendInst opBranchDecode(RawInst inst);
    SType decoded_inst = unpack(inst);

    BackendInst return_inst;
    BruCtrl bru_ctrl = BruCtrl {op: EQ, src: PcImm};  // default value
    Word b_imm = signExtend({inst[31], inst[7], inst[30:25], inst[11:8], 1'b0});

    Bool isInvalid = False;

    case (decoded_inst.funct3)
      'b000: bru_ctrl = BruCtrl {op: EQ, src: PcImm};
      'b001: bru_ctrl = BruCtrl {op: NE, src: PcImm};
      'b100: bru_ctrl = BruCtrl {op: LT, src: PcImm};
      'b101: bru_ctrl = BruCtrl {op: GE, src: PcImm};
      'b110: bru_ctrl = BruCtrl {op: LTU, src: PcImm};
      'b111: bru_ctrl = BruCtrl {op: GEU, src: PcImm};
      default: isInvalid = True;
    endcase

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: decoded_inst.rs2,
      rd: 0,
      imm: b_imm,
      csr: 0,
      fu: tagged BRU bru_ctrl,
      trap: (isInvalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opLoadDecode
  //   Decode the instructions with opcode = LOAD.
  function BackendInst opLoadDecode(RawInst inst);
    IType decoded_inst = unpack(inst);

    BackendInst return_inst;
    LsuCtrl lsu_ctrl = LsuCtrl {op: LW, src: Rs1Imm};  // default value
    Word i_imm = signExtend(inst[31:20]);

    Bool isInvalid = False;

    case (decoded_inst.funct3)
      'b000: lsu_ctrl = LsuCtrl {op: LB, src: Rs1Imm};
      'b001: lsu_ctrl = LsuCtrl {op: LH, src: Rs1Imm};
      'b010: lsu_ctrl = LsuCtrl {op: LW, src: Rs1Imm};
      'b100: lsu_ctrl = LsuCtrl {op: LBU, src: Rs1Imm};
      'b101: lsu_ctrl = LsuCtrl {op: LHU, src: Rs1Imm};
      default: isInvalid = True;
    endcase

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: i_imm,
      csr: 0,
      fu: tagged LSU lsu_ctrl,
      trap: (isInvalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opStoreDecode
  //   Decode the instructions with opcode = STORE.
  function BackendInst opStoreDecode(RawInst inst);
    SType decoded_inst = unpack(inst);

    BackendInst return_inst;
    LsuCtrl lsu_ctrl = LsuCtrl {op: SW, src: Rs1Rs2Imm};  // default value
    Word s_imm = signExtend({inst[31:25], inst[11:7]});

    Bool isInvalid = False;

    case (decoded_inst.funct3)
      'b000: lsu_ctrl = LsuCtrl {op: SB, src: Rs1Rs2Imm};
      'b001: lsu_ctrl = LsuCtrl {op: SH, src: Rs1Rs2Imm};
      'b010: lsu_ctrl = LsuCtrl {op: SW, src: Rs1Rs2Imm};
      default: isInvalid = True;
    endcase

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: decoded_inst.rs2,
      rd: 0,
      imm: s_imm,
      csr: 0,
      fu: tagged LSU lsu_ctrl,
      trap: (isInvalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
    };
    return return_inst;
  endfunction

  // Function: opCsrDecode
  //   Decode the instructions with opcode = CSR.
  function BackendInst opCsrDecode(RawInst inst);
    IType decoded_inst = unpack(inst);

    BackendInst return_inst;
    CsruCtrl csru_ctrl = CsruCtrl {op: RW, src: Rs1};  // default value

    Bool isInvalid = False;

    case (decoded_inst.funct3)
      'b001: csru_ctrl = CsruCtrl {op: RW, src: Rs1};
      'b010: csru_ctrl = CsruCtrl {op: RS, src: Rs1};
      'b011: csru_ctrl = CsruCtrl {op: RC, src: Rs1};
      'b101: csru_ctrl = CsruCtrl {op: RW, src: Uimm};
      'b110: csru_ctrl = CsruCtrl {op: RS, src: Uimm};
      'b111: csru_ctrl = CsruCtrl {op: RC, src: Uimm};
      default: isInvalid = True;
    endcase

    return_inst = BackendInst {
      pc: ?,
      rs1: decoded_inst.rs1,
      rs2: 0,
      rd: decoded_inst.rd,
      imm: zeroExtend(pack(decoded_inst.rs1)),
      csr: unpack(decoded_inst.imm),
      fu: tagged CSRU csru_ctrl,
      trap: (isInvalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
    };
    return return_inst;
  endfunction

  method BackendInst decode(RawInst inst, Word pc);
    BackendInst return_inst = BackendInst {  // default value
      pc: pc,
      rs1: 0,
      rs2: 0,
      rd: 0,
      imm: 0,
      csr: 0,
      fu: tagged ALU AluCtrl {op: ADD, src: Rs1Imm},
      trap: tagged Invalid
    };

    Bit#(OpCodeWidth) opcode = inst[6:0];

    case (opcode)
      op_imm    : return_inst = opImmDecode(inst);
      op_r      : return_inst = opRDecode(inst);
      op_lui    : return_inst = opLuiDecode(inst);
      op_auipc  : return_inst = opAuipcDecode(inst);
      op_jal    : return_inst = opJalDecode(inst);
      op_jalr   : return_inst = opJalrDecode(inst);
      op_branch : return_inst = opBranchDecode(inst);
      op_load   : return_inst = opLoadDecode(inst);
      op_store  : return_inst = opStoreDecode(inst);
      op_csr    : return_inst = opCsrDecode(inst);
      default   : return_inst.trap = tagged Valid TrapCause {isInterrupt: False, code: 2};
    endcase

    return_inst.pc = pc;

    if (isValid(return_inst.trap)) begin
      return_inst.fu = tagged ALU AluCtrl {op: ADD, src: Rs1Imm};
      return_inst.rs1 = 0;
      return_inst.rs2 = 0;
      return_inst.rd = 0;
      return_inst.imm = 0;
      return_inst.csr = 0;
    end
    return return_inst;
  endmethod
endmodule
endpackage
