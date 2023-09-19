package OboeFutureRegMap;
import Vector::*;
import OboeTypeDef::*;

typedef struct {
  Bool isOutdated;
  Tag tag;
} RegMapEntry;

interface OboeFutureRegMap;
  method RegMapEntry lookup(ArchRegId index);
  method Action rename(ArchRegId index, Tag value);
  method Action restore(Vector #(NumRegs, Reg#(Tag)) arm);
endinterface

module mkOboeFutureRegMap(OboeFutureRegMap);
  Vector #(NumRegs, Reg#(Tag)) tagVector;
  Vector #(NumRegs, Reg#(Bool)) outdatedVector <- replicateM(mkReg(False));

  for (Integer i = 0; i < valueOf(NumRegs); i = i + 1) begin
    tagVector[i] <- mkReg(fromInteger(i));
  end

  method RegMapEntry lookup(ArchRegId index);
    if (index == 0) begin
      return RegMapEntry {isOutdated: False, tag: 0};
    end else begin
      return RegMapEntry {isOutdated: outdatedVector[index], tag: tagVector[index]};
    end
  endmethod

  method Action rename(ArchRegId index, Tag value);
    if (index != 0) begin
      outdatedVector[index] <= True;
      tagVector[index] <= value;
    end
  endmethod

  method Action restore(Vector #(NumRegs, Reg#(Tag)) arm);
    for (Integer i = 0; i < valueOf(NumRegs); i = i + 1) begin
      tagVector[i] <= arm[i];
      outdatedVector[i] <= False;
    end
  endmethod

endmodule
endpackage
