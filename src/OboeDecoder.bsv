package OboeDecoder;
import OboeTypeDef::*;

// Typedef: RType
//   R-type instruction format.
typedef struct {
  Bit#(7) funct7;
  Bit#(5) rs2;
  Bit#(5) rs1;
  Bit#(3) funct3;
  Bit#(5) rd;
  Bit#(7) opcode;
} RType deriving(Eq, Bits);

// Typedef: IType
//   I-type instruction format.
typedef struct {
  Bit#(12) imm;
  Bit#(5) rs1;
  Bit#(3) funct3;
  Bit#(5) rd;
  Bit#(7) opcode;
} IType deriving(Eq, Bits);

// Typedef: SType
//   S-type instruction format.
typedef struct {
  Bit#(7) imm2;
  Bit#(5) rs2;
  Bit#(5) rs1;
  Bit#(3) funct3;
  Bit#(5) imm1;
  Bit#(7) opcode;
} SType deriving(Eq, Bits);

// Typedef: UType
//   U-type instruction format.
typedef struct {
  Bit#(20) imm;
  Bit#(5) rd;
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

  // Function: immTypeDecode
  //   Decode the instructions with opcode = OP_IMM
  function BackendInst immTypeDecode(RawInst inst, Word pc);
    IType decoded_inst = unpack(inst);
    AluCtrl alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};  // default value
    Word imm = signExtend(decoded_inst.imm);
    Bool invalid = False;
    case (decoded_inst.funct3)
      'b000: alu_ctrl = AluCtrl {op: ADD, src: Rs1Imm};
      'b100: alu_ctrl = AluCtrl {op: XOR, src: Rs1Imm};
      'b110: alu_ctrl = AluCtrl {op: OR, src: Rs1Imm};
      'b111: alu_ctrl = AluCtrl {op: AND, src: Rs1Imm};
      'b010: alu_ctrl = AluCtrl {op: LT, src: Rs1Imm};
      'b011: begin 
        imm = zeroExtend(decoded_inst.imm);
        alu_ctrl = AluCtrl {op: LTU, src: Rs1Imm}; 
      end
      'b001: begin 
        imm = zeroExtend(decoded_inst.imm[4:0]);
        alu_ctrl = AluCtrl {op: SLL, src: Rs1Imm};
      end
      'b101: begin 
        imm = zeroExtend(decoded_inst.imm[4:0]);
        if (|inst[31:25] == 0)
          alu_ctrl = AluCtrl {op: SRL, src: Rs1Imm};
        else if (inst[31:25] == 'b0100000)
          alu_ctrl = AluCtrl {op: SRA, src: Rs1Imm};
        else
          invalid = True;
      end
      default:
        invalid = True;
    endcase
    BackendInst return_inst = BackendInst {
      pc: pc,
      rs1: unpack(decoded_inst.rs1),
      rs2: 0,
      rd: unpack(decoded_inst.rd),
      imm: imm,
      fu: tagged ALU alu_ctrl,
      trap: (invalid)? tagged Valid TrapCause {isInterrupt: False, code: 2} : tagged Invalid
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
      fu: tagged ALU AluCtrl {op: ADD, src: Rs1Imm},
      trap: tagged Invalid
    };

    Bit#(OpCodeWidth) opcode = inst[6:0];

    case (opcode)
    op_imm: return_inst = immTypeDecode(inst, pc);
    endcase

    return return_inst;
  endmethod
endmodule
endpackage
