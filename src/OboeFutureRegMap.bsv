package OboeFutureRegMap;

import Vector::*;
import GetPut::*;

import OboeTypeDef::*;
import OboeConfig::*;

// Interface: OboeFutureRegMap
interface OboeFutureRegMap;
  // Method: lookup
  //   Lookup the tag for physical register file in future register map.
  //
  // Parameter:
  //   index - Architectural register index to look up in future register map.
  //
  // Returns:
  //   Tuple2 for Bool and <Tag>. The Bool value indicates the outdated status of the entry.
  method Tuple2#(Bool, Tag) lookup(ArchRegId index);
  // Method: rename
  //   Rename the future register map entry with the given tag.
  //
  // Parameter:
  //   rd  - The ID of the destination register to be renamed
  //   tag - Tag to rename.
  method Action rename(ArchRegId rd, Tag tag);
  // Subinterface: wbPorts
  //   A Vector of Put interface for write back request from execution units. EXU puts the 
  //   <ArchRegId> rd in the put method to indicate the corresponding instruction finishes execution.
  interface Vector#(NumWbPorts, Put#(ArchRegId)) wbPorts;
  // Method: restore
  //   Update all the entries in future register map with entries in architectural register map.
  //
  // Parameter:
  //   arm - The whole architectural register map vector.
  method Action restore(Vector #(NumArchRegs, Reg#(Tag)) arm);
endinterface

// Module: mkOboeFutureRegMap
//   The future register map is in charge of maintaining the renamed tags. The module contains two 
//   vectors: tag_vector and outdated_vector. The combination of the two is the future register map.
module mkOboeFutureRegMap(OboeFutureRegMap);
  Vector #(NumArchRegs, Reg#(Tag)) tag_vector;
  Vector #(NumArchRegs, Array#(Reg#(Bool))) outdated_vector <- 
      replicateM(mkCReg(kNumWbPorts + 1, False));

  for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
    tag_vector[i] <- mkReg(fromInteger(i));
  end

  // Function: genWbPort
  //   Function to generate a Put interface with index i.
  //
  // Parameter:
  //   i - Port index.
  //
  // Return:
  //   The Put interface at index i.
  function Put#(ArchRegId) genWbPort(Integer i);
    let wb_port =
      (interface Put#(ArchRegId);
        method Action put(ArchRegId rd);
          outdated_vector[rd][i] <= False;
        endmethod
      endinterface);
    return wb_port;
  endfunction

  interface Vector wbPorts = map(genWbPort, genVector);

  method Tuple2#(Bool, Tag) lookup(ArchRegId index);
    if (index == 0) begin
      return tuple2(False, 0);  // is_outdated = False, tag = 0
    end else begin
      return tuple2(outdated_vector[index][kNumWbPorts], tag_vector[index]);
    end
  endmethod

  method Action rename(ArchRegId rd, Tag tag);
    if (rd != 0) begin
      outdated_vector[rd][kNumWbPorts] <= True;
      tag_vector[rd] <= tag;
    end
  endmethod

  method Action restore(Vector #(NumArchRegs, Reg#(Tag)) arm);
    for (Integer i = 0; i < kNumArchRegs; i = i + 1) begin
      tag_vector[i] <= arm[i];
      outdated_vector[i][kNumWbPorts] <= False;
    end
  endmethod

endmodule

endpackage
