package OboeArchitectureRegMap;
import Vector::*;
import OboeTypeDef::*;

interface OboeArchitectureRegMap;
  method ActionValue#(Tag) commit(ArchRegId index, Tag commit_ptr);
  method Vector#(NumArchRegs, Reg#(Tag)) forward;  // forward to FRM
endinterface

module mkOboeArchitectureRegMap(OboeArchitectureRegMap);
  Vector #(NumArchRegs, Reg#(Tag)) tagVector;

  for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
    tagVector[i] <- mkReg(fromInteger(i));
  end

  // commit the pointer tag to the ARM and return the corresponding old tag
  method ActionValue#(Tag) commit(ArchRegId index, Tag commit_ptr);
    if (index == 0) begin
      return 0;
    end else begin
      Tag tmp_tag = tagVector[index];
      tagVector[index] <= commit_ptr;
      return tmp_tag;
    end
  endmethod

  method forward = tagVector;

endmodule
endpackage
