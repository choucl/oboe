package OboeDecoder;

import OboeTypeDef::*;

// Function: immIType
//   Generate I-type immediate value
function Word immIType(IType inst) = signExtend(inst.imm);

// Function: immSType
//   Generate S-type immediate value
function Word immSType(SType inst) = signExtend({inst.imm2, inst.imm1});

// Function: immUType
//   Generate U-type immediate value
function Word immUType(UType inst) = {inst.imm, 12'd0};

// Function: immJType
//   Generate J-type immediate value
function Word immJType(JType inst) = signExtend({inst.imm4, inst.imm3, inst.imm2, inst.imm1, 1'b0}); 

// Function: immBType
//   Generate B-type immediate value
function Word immBType(BType inst) = signExtend({inst.imm4, inst.imm3, inst.imm2, inst.imm1, 1'b0}); 

TrapCause illegal_instruction = TrapCause {isInterrupt: False, code: 2};

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

  // Function: decodeOpImm
  //   Decode the instructions with opcode = OP_IMM.
  function BackendInst decodeOpImm(RawInst inst);
    IType decoded_inst = unpack(inst);
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};  // default value
    Bool isIllegal = False;

    case (decoded_inst.funct3)
      funct3_add:  alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};
      funct3_xor:  alu_ctrl = AluCtrl {op: XOR, src: Rs1Imm};
      funct3_or:   alu_ctrl = AluCtrl {op: OR,  src: Rs1Imm};
      funct3_and:  alu_ctrl = AluCtrl {op: AND, src: Rs1Imm};
      funct3_slt:  alu_ctrl = AluCtrl {op: LT,  src: Rs1Imm};
      funct3_sltu: alu_ctrl = AluCtrl {op: LTU, src: Rs1Imm}; 
      funct3_sll: begin
        if (decoded_inst.imm[11:5] == 0)
          alu_ctrl = AluCtrl {op: SLL, src: Rs1Imm};
        else
          isIllegal = True;
      end
      funct3_srl: begin 
        if (decoded_inst.imm[11:5] == 0)
          alu_ctrl = AluCtrl {op: SRL, src: Rs1Imm};
        else if (inst[31:25] == 'b0100000)
          alu_ctrl = AluCtrl {op: SRA, src: Rs1Imm};
        else
          isIllegal = True;
      end
      default:
        isIllegal = True;
    endcase

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  immIType(decoded_inst),
      fu:   tagged ALU alu_ctrl,
      trap: (isIllegal)? tagged Valid illegal_instruction : tagged Invalid
    };
  endfunction

  // Function: decodeLui
  //   Decode the instructions with opcode = LUI.
  function BackendInst decodeLui(RawInst inst);
    UType decoded_inst = unpack(inst);
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};  // default value

    return BackendInst {
      pc:   ?,
      rs1:  0,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  immUType(decoded_inst),
      fu:   tagged ALU alu_ctrl,
      trap: tagged Invalid
    };
  endfunction

  // Function: decodeAuipc
  //   Decode the instructions with opcode = AUIPC.
  function BackendInst decodeAuipc(RawInst inst);
    UType decoded_inst = unpack(inst);
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: PcImm};  // default value

    return BackendInst {
      pc:   ?,
      rs1:  0,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  immUType(decoded_inst),
      fu:   tagged ALU alu_ctrl,
      trap: tagged Invalid
    };
  endfunction

  // Function: decodeOp
  //   Decode the instructions with opcode = OP.
  function BackendInst decodeOp(RawInst inst);
    RType decoded_inst = unpack(inst);
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Rs2};  // default value
    Bool isIllegal = False;

    case ({decoded_inst.funct7, decoded_inst.funct3})
      {'b0000000, funct3_add}:  alu_ctrl = AluCtrl {op: ADD, src: Rs1Rs2}; 
      {'b0100000, funct3_add}:  alu_ctrl = AluCtrl {op: SUB, src: Rs1Rs2}; 
      {'b0000000, funct3_slt}:  alu_ctrl = AluCtrl {op: LT,  src: Rs1Rs2};
      {'b0000000, funct3_sltu}: alu_ctrl = AluCtrl {op: LTU, src: Rs1Rs2};
      {'b0000000, funct3_and}:  alu_ctrl = AluCtrl {op: AND, src: Rs1Rs2};
      {'b0000000, funct3_or}:   alu_ctrl = AluCtrl {op: OR,  src: Rs1Rs2};
      {'b0000000, funct3_xor}:  alu_ctrl = AluCtrl {op: XOR, src: Rs1Rs2};
      {'b0000000, funct3_sll}:  alu_ctrl = AluCtrl {op: SLL, src: Rs1Rs2};
      {'b0000000, funct3_srl}:  alu_ctrl = AluCtrl {op: SRL, src: Rs1Rs2}; 
      {'b0100000, funct3_srl}:  alu_ctrl = AluCtrl {op: SRA, src: Rs1Rs2};
      default: isIllegal = True;
    endcase

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  decoded_inst.rs2,
      rd:   decoded_inst.rd,
      imm:  0,
      fu:   tagged ALU alu_ctrl,
      trap: (isIllegal)? tagged Valid illegal_instruction : tagged Invalid
    };
  endfunction
  
  // Function: decodeJal
  //   Decode the instructions with opcode = JAL.
  function BackendInst decodeJal(RawInst inst);
    JType decoded_inst = unpack(inst);
    BruCtrl bru_ctrl = BruCtrl {op: JAL, src: PcImm};  // default value

    return BackendInst {
      pc:   ?,
      rs1:  0,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  immJType(decoded_inst),
      fu:   tagged BRU bru_ctrl,
      trap: tagged Invalid
    };
  endfunction

  // Function: decodeJalr
  //   Decode the instructions with opcode = JALR.
  function BackendInst decodeJalr(RawInst inst);
    IType decoded_inst = unpack(inst);
    BruCtrl bru_ctrl = BruCtrl {op: JAL, src: Rs1Imm};  // default value

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  immIType(decoded_inst),
      fu:   tagged BRU bru_ctrl,
      trap: tagged Invalid
    };
  endfunction

  // Function: decodeBranch
  //   Decode the instructions with opcode = BRANCH.
  function BackendInst decodeBranch(RawInst inst);
    BType decoded_inst = unpack(inst);
    BruCtrl bru_ctrl = BruCtrl {op: EQ, src: PcImm};  // default value
    Bool isIllegal = False;

    case (decoded_inst.funct3)
      funct3_beq:  bru_ctrl = BruCtrl {op: EQ,  src: PcImm};
      funct3_bne:  bru_ctrl = BruCtrl {op: NE,  src: PcImm};
      funct3_blt:  bru_ctrl = BruCtrl {op: LT,  src: PcImm};
      funct3_bge:  bru_ctrl = BruCtrl {op: GE,  src: PcImm};
      funct3_bltu: bru_ctrl = BruCtrl {op: LTU, src: PcImm};
      funct3_bgeu: bru_ctrl = BruCtrl {op: GEU, src: PcImm};
      default: isIllegal = True;
    endcase

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  decoded_inst.rs2,
      rd:   0,
      imm:  immBType(decoded_inst),
      fu:   tagged BRU bru_ctrl,
      trap: (isIllegal)? tagged Valid illegal_instruction : tagged Invalid
    };
  endfunction

  // Function: decodeLoad
  //   Decode the instructions with opcode = LOAD.
  function BackendInst decodeLoad(RawInst inst);
    IType decoded_inst = unpack(inst);
    LsuCtrl lsu_ctrl = LsuCtrl {op: LW, src: Rs1Imm};  // default value
    Bool isIllegal = False;

    case (decoded_inst.funct3)
      funct3_lb:  lsu_ctrl = LsuCtrl {op: LB, src: Rs1Imm};
      funct3_lh:  lsu_ctrl = LsuCtrl {op: LH, src: Rs1Imm};
      funct3_lw:  lsu_ctrl = LsuCtrl {op: LW, src: Rs1Imm};
      funct3_lbu: lsu_ctrl = LsuCtrl {op: LBU, src: Rs1Imm};
      funct3_lhu: lsu_ctrl = LsuCtrl {op: LHU, src: Rs1Imm};
      default: isIllegal = True;
    endcase

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  immIType(decoded_inst),
      fu:   tagged LSU lsu_ctrl,
      trap: (isIllegal)? tagged Valid illegal_instruction : tagged Invalid
    };
  endfunction

  // Function: decodeStore
  //   Decode the instructions with opcode = STORE.
  function BackendInst decodeStore(RawInst inst);
    SType decoded_inst = unpack(inst);
    LsuCtrl lsu_ctrl = LsuCtrl {op: SW, src: Rs1Rs2Imm};  // default value
    Bool isIllegal = False;

    case (decoded_inst.funct3)
      funct3_sb: lsu_ctrl = LsuCtrl {op: SB, src: Rs1Rs2Imm};
      funct3_sh: lsu_ctrl = LsuCtrl {op: SH, src: Rs1Rs2Imm};
      funct3_sw: lsu_ctrl = LsuCtrl {op: SW, src: Rs1Rs2Imm};
      default: isIllegal = True;
    endcase

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  decoded_inst.rs2,
      rd:   0,
      imm:  immSType(decoded_inst),
      fu:   tagged LSU lsu_ctrl,
      trap: (isIllegal)? tagged Valid illegal_instruction : tagged Invalid
    };
  endfunction

  // Function: decodeSystem
  //   Decode the instructions with opcode = CSR.
  function BackendInst decodeSystem(RawInst inst);
    IType decoded_inst = unpack(inst);
    CsruCtrl csru_ctrl = CsruCtrl {op: RW, src: Rs1};  // default value
    Bool isIllegal = False;

    case (decoded_inst.funct3)
      funct3_csrrw:  csru_ctrl = CsruCtrl {op: RW, src: Rs1};
      funct3_csrrs:  csru_ctrl = CsruCtrl {op: RS, src: Rs1};
      funct3_csrrc:  csru_ctrl = CsruCtrl {op: RC, src: Rs1};
      funct3_csrrwi: csru_ctrl = CsruCtrl {op: RW, src: Uimm};
      funct3_csrrsi: csru_ctrl = CsruCtrl {op: RS, src: Uimm};
      funct3_csrrci: csru_ctrl = CsruCtrl {op: RC, src: Uimm};
      funct3_priv: begin
        // TODO: decode privileged instructions
        isIllegal = True;
      end
      default: isIllegal = True;
    endcase

    return BackendInst {
      pc:   ?,
      rs1:  decoded_inst.rs1,
      rs2:  0,
      rd:   decoded_inst.rd,
      imm:  zeroExtend(decoded_inst.imm),
      fu:   tagged CSRU csru_ctrl,
      trap: (isIllegal)? tagged Valid illegal_instruction : tagged Invalid
    };
  endfunction

  method BackendInst decode(RawInst inst, Word pc);
    BackendInst return_inst = ?;
    Opcode opcode = inst[6:0];

    // Decode instructoin based on its opcode.
    case (opcode)
      opcode_op_imm: return_inst = decodeOpImm(inst);
      opcode_op:     return_inst = decodeOp(inst);
      opcode_lui:    return_inst = decodeLui(inst);
      opcode_auipc:  return_inst = decodeAuipc(inst);
      opcode_jal:    return_inst = decodeJal(inst);
      opcode_jalr:   return_inst = decodeJalr(inst);
      opcode_branch: return_inst = decodeBranch(inst);
      opcode_load:   return_inst = decodeLoad(inst);
      opcode_store:  return_inst = decodeStore(inst);
      opcode_system: return_inst = decodeSystem(inst);
      default: return_inst.trap = tagged Valid illegal_instruction;
    endcase

    return_inst.pc = pc;

    if (isValid(return_inst.trap)) begin
      return_inst.fu = tagged Invalid;
      return_inst.rs1 = 0;
      return_inst.rs2 = 0;
      return_inst.rd = 0;
      return_inst.imm = 0;
    end

    return return_inst;
  endmethod

endmodule

endpackage
