package OboeDecoderTb;
import Vector::*;
import GetPut::*;
import StmtFSM::*;
import OboeTypeDef::*;
import OboeDecoder::*;

module mkOboeDecoderTb();
  OboeDecoder dec <- mkOboeDecoder();

  function RawInst branch(ArchRegId rs1, ArchRegId rs2, Bit#(3) funct3, Bit#(12) imm);
    return unpack(pack(SType {rs1: rs1, rs2: rs2, funct3: funct3,
                              imm2: {imm[11], imm[9:4]},
                              imm1: {imm[3:0], imm[10]},
                              opcode: opcode_branch}));
  endfunction

  function RawInst store(ArchRegId rs1, ArchRegId rs2, Bit#(3) funct3, Bit#(12) imm);
    return unpack(pack(SType {rs1: rs1, rs2: rs2, funct3: funct3,
                              imm2: imm[11:5], imm1: imm[4:0], 
                              opcode: opcode_store}));
  endfunction

  function RawInst jal(ArchRegId rd, Bit#(20) imm);
    return unpack(pack(UType {rd: rd, imm: {imm[19], imm[9:0], imm[10], imm[18:11]},
                              opcode: opcode_jal}));
  endfunction

  function Action test_instruction(RawInst inst);
    return 
      action
        BackendInst bi = dec.decode(inst, ?);
        $display(fshow(bi));
      endaction;
  endfunction

  mkAutoFSM(
    seq
      $display("U-type instruction");
      test_instruction(unpack(pack(UType {imm: 87, rd: 15, opcode: opcode_lui})));
      test_instruction(unpack(pack(UType {imm: 87, rd: 15, opcode: opcode_auipc})));

      $display("\nJ-type instruction");
      test_instruction(jal(15, 87));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 0, rd: 15, opcode: opcode_jalr})));

      $display("\nB-type instruction");
      test_instruction(branch(1, 2, 'b000, 87));
      test_instruction(branch(1, 2, 'b001, 87));
      test_instruction(branch(1, 2, 'b100, 87));
      test_instruction(branch(1, 2, 'b110, 87));
      test_instruction(branch(1, 2, 'b111, 87));

      $display("\nLoad instruction");
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 0, rd: 15, opcode: opcode_load})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b001, rd: 15, opcode: opcode_load})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b010, rd: 15, opcode: opcode_load})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b101, rd: 15, opcode: opcode_load})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b100, rd: 15, opcode: opcode_load})));

      $display("\nS-type instruction");
      test_instruction(store(1, 2, 'b000, 87));
      test_instruction(store(1, 2, 'b001, 87));
      test_instruction(store(1, 2, 'b010, 87));

      $display("\nI-type instruction");
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 0, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b010, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b011, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b100, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b110, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b111, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 10, rs1: 1, funct3: 'b001, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: 10, rs1: 1, funct3: 'b101, rd: 15, opcode: opcode_op_imm})));
      test_instruction(unpack(pack(IType {imm: {'b0100000, 5'd10}, rs1: 1, funct3: 'b101, rd: 15, opcode: opcode_op_imm})));

      $display("\nR-type instruction");
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b000, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0100000, rs1: 1, rs2:2, funct3: 'b000, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b001, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b010, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b011, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b100, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b101, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0100000, rs1: 1, rs2:2, funct3: 'b101, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b110, rd: 15, opcode: opcode_op})));
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b111, rd: 15, opcode: opcode_op})));

      $display("\nCSR instruction");
      test_instruction(unpack(pack(IType {imm: 150, rs1: 1, funct3: 'b001, rd: 15, opcode: opcode_system})));
      test_instruction(unpack(pack(IType {imm: 150, rs1: 1, funct3: 'b010, rd: 15, opcode: opcode_system})));
      test_instruction(unpack(pack(IType {imm: 150, rs1: 1, funct3: 'b011, rd: 15, opcode: opcode_system})));
      test_instruction(unpack(pack(IType {imm: 150, rs1: 21, funct3: 'b101, rd: 15, opcode: opcode_system})));
      test_instruction(unpack(pack(IType {imm: 150, rs1: 21, funct3: 'b110, rd: 15, opcode: opcode_system})));
      test_instruction(unpack(pack(IType {imm: 150, rs1: 21, funct3: 'b111, rd: 15, opcode: opcode_system})));

      // Illegal instructions
      $display("\nIllegal instructions");
      // Unknown OP
      test_instruction(unpack(pack(RType {funct7: 'b0000000, rs1: 1, rs2:2, funct3: 'b111, rd: 15, opcode: 'b1000000})));
      // Unknown function3 
      test_instruction(unpack(pack(IType {imm: 87, rs1: 1, funct3: 'b111, rd: 15, opcode: opcode_load})));
      test_instruction(store(1, 2, 'b111, -1));
      // Unknown shift op
      test_instruction(unpack(pack(IType {imm: {'b1000000, 5'd10}, rs1: 1, funct3: 'b101, rd: 15, opcode: opcode_op_imm})));
      // Unknown function 7
      test_instruction(unpack(pack(RType {funct7: 'b1000000, rs1: 1, rs2:2, funct3: 'b000, rd: 15, opcode: opcode_op})));
    endseq
  );

endmodule
endpackage
