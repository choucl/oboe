package OboeRegAliasTable;

import Vector::*;
import GetPut::*;

import OboeTypeDef::*;
import OboeFutureRegMap::*;
import OboeArchitectureRegMap::*;
import OboeConfig::*;

// Interface: OboeRegAliasTable
interface OboeRegAliasTable;
  // Method: lookup
  //   See <OboeFutureRegMap.lookup>.
  method Tuple2#(Bool, Tag) lookup(ArchRegId index);
  // Method: rename
  //   See <OboeFutureRegMap.rename>.
  method Action rename(ArchRegId index, Tag value);
  // Subinterface: wbPorts
  //   See <OboeFutureRegMap.wbPorts>.
  interface Vector#(NumWbPorts, Put#(ArchRegId)) wbPorts;
  // Method: commit
  //   See <OboeArchitectureRegMap.commit>.
  method ActionValue#(Tag) commit(ArchRegId index, Tag commit_ptr);
  // Method: restore
  //   Restore the future register map with the architecture register map. The method is used 
  //   flushing is needed.
  method Action restore();
endinterface

// Module: mkOboeRegAliasTable
//   This module includes two register map instances: <mkOboeArchitectureRegMap> and 
//   <mkOboeFutureRegMap>. 
//   The module uses method <restore> to handle the restoration between two register maps.
module mkOboeRegAliasTable(OboeRegAliasTable);
  OboeFutureRegMap frm <- mkOboeFutureRegMap();
  OboeArchitectureRegMap arm <- mkOboeArchitectureRegMap();

  interface wbPorts = frm.wbPorts;

  method lookup = frm.lookup;
  method rename = frm.rename;
  method commit = arm.commit;
  method Action restore() = frm.restore(arm.forward);
endmodule

endpackage
