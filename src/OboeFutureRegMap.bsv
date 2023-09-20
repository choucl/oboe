package OboeFutureRegMap;
import Vector::*;
import OboeTypeDef::*;

// Struct: RegMapEntry
//   Entry for future register map.
//
// Variable:
//   isOutdated - Indicates the register has been renamed 
//   tag - The pointer for physical register file
typedef struct {
  Bool isOutdated;
  Tag tag;
} RegMapEntry;

// Interface: OboeFutureRegMap
interface OboeFutureRegMap;
  // Method: lookup
  //   Lookup the tag for physical register file in future register map.
  //
  // Variable:
  //   index - Architectural register index to look up in future register map.
  //
  // Returns:
  //   <RegMapEntry> for the corresponding index.
  method RegMapEntry lookup(ArchRegId index);

  // Method: rename
  //   Rename the future register map entry with the given tag.
  //
  // Variable:
  //   index - Architectural register index to look up in future register map.
  //   value - Tag to rename.
  method Action rename(ArchRegId index, Tag value);

  // Method: restore
  //   Update all the entries in future register map with entries in architectural register map.
  //
  // Variable:
  //   arm - The whole architectural register map vector.
  method Action restore(Vector #(NumArchRegs, Reg#(Tag)) arm);
endinterface

// Module: mkOboeFutureRegMap
//   The future register map is in charge of maintaining the renamed tags. The module contains two 
//   vectors: tag_vector and outdated_vector. The combination of the two is the future register map.
module mkOboeFutureRegMap(OboeFutureRegMap);
  Vector #(NumArchRegs, Reg#(Tag)) tag_vector;
  Vector #(NumArchRegs, Reg#(Bool)) outdated_vector <- replicateM(mkReg(False));

  for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
    tag_vector[i] <- mkReg(fromInteger(i));
  end

  method RegMapEntry lookup(ArchRegId index);
    if (index == 0) begin
      return RegMapEntry {isOutdated: False, tag: 0};
    end else begin
      return RegMapEntry {isOutdated: outdated_vector[index], tag: tag_vector[index]};
    end
  endmethod

  method Action rename(ArchRegId index, Tag value);
    if (index != 0) begin
      outdated_vector[index] <= True;
      tag_vector[index] <= value;
    end
  endmethod

  method Action restore(Vector #(NumArchRegs, Reg#(Tag)) arm);
    for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
      tag_vector[i] <= arm[i];
      outdated_vector[i] <= False;
    end
  endmethod

endmodule
endpackage
