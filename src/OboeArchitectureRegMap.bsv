package OboeArchitectureRegMap;

import Vector::*;

import OboeTypeDef::*;

// Interface: OboeArchitectureRegMap
interface OboeArchitectureRegMap;
  // Method: commit
  //   Update the tag in architectural register map and return the old tag.
  //    When rd = 0, return the commit_ptr directly.
  //
  // Parameter:
  //   rd         - Destination register to be committed.
  //   commit_ptr - The commit tag to be stored.
  //
  // Returns:
  //   The old tag of the destination register.
  method ActionValue#(Tag) commit(ArchRegId rd, Tag commit_ptr);
  // Method: forward
  //   Return the whole architectural register map for restoring future register map.
  //   See <OboeFutureRegMap.restore>.
  //
  // Returns:
  //   The whole architectural register map vector.
  method Vector#(NumArchRegs, Reg#(Tag)) forward;  // forward to FRM
endinterface

// Module: mkOboeArchitectureRegMap
//   The architecture register map is in charge of maintaining the architectural state of all the
//   logical registers. Logical registers map to the physical registers by looking up the
//   tag_vector. tag_vector is forwarded to the <mkOboeFutureRegMap> when restoring.
module mkOboeArchitectureRegMap(OboeArchitectureRegMap);
  Vector #(NumArchRegs, Reg#(Tag)) tag_vector;

  for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
    tag_vector[i] <- mkReg(fromInteger(i));
  end

  method ActionValue#(Tag) commit(ArchRegId rd, Tag commit_ptr);
    if (rd == 0) begin
      return commit_ptr;
    end else begin
      Tag tmp_tag = tag_vector[rd];
      tag_vector[rd] <= commit_ptr;
      return tmp_tag;
    end
  endmethod

  method forward = tag_vector;

endmodule

endpackage
