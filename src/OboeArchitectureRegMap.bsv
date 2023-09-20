package OboeArchitectureRegMap;

import Vector::*;

import OboeTypeDef::*;

// Interface: OboeArchitectureRegMap
interface OboeArchitectureRegMap;
  // Method: commit
  //   Update the tag in architectural register map and return the old tag.
  //
  // Parameter:
  //   index      - Architectural register index to look up in architectural register map.
  //   commit_ptr - The commit tag to be stored.
  //
  // Returns:
  //   The old tag in the given index.
  method ActionValue#(Tag) commit(ArchRegId index, Tag commit_ptr);
  // Method: forward
  //   Return the whole architectural register map for restoring future register map.
  //   See <OboeFutureRegMap.restore>.
  //
  // Returns:
  //   The whole architectural register map vector.
  method Vector#(NumArchRegs, Reg#(Tag)) forward;  // forward to FRM
endinterface

module mkOboeArchitectureRegMap(OboeArchitectureRegMap);
  Vector #(NumArchRegs, Reg#(Tag)) tagVector;

  for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
    tagVector[i] <- mkReg(fromInteger(i));
  end

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
