package OboeRenameTable;
import Vector::*;
import OboeTypeDef::*;
import OboeFutureRegMap::*;
import OboeArchitectureRegMap::*;

interface OboeRenameTable;
  method RegMapEntry lookup(ArchRegId index);
  method Action rename(ArchRegId index, Tag value);
  method ActionValue#(Tag) commit(ArchRegId index, Tag commit_ptr);
  method Action restore();
endinterface

module mkOboeRenameTable(OboeRenameTable);
  OboeFutureRegMap frm <- mkOboeFutureRegMap();
  OboeArchitectureRegMap arm <- mkOboeArchitectureRegMap();

  method lookup = frm.lookup;
  method rename = frm.rename;
  method commit = arm.commit;
  method Action restore();
    frm.restore(arm.forward);
  endmethod
endmodule
endpackage
