package OboeScheduler;

import Vector::*;
import GetPut::*;

import OboeConfig::*;
import OboeTypeDef::*;
import OboeReorderBuffer::*;
import OboeRegAliasTable::*;

interface OboeScheduler;
  interface Put#(BackendInst) renamePort;
  interface Vector#(NumWbPorts, Put#(Tuple2#(ArchRegId, Tag))) wbPorts;
endinterface

module mkOboeScheduler (OboeScheduler);
  OboeReorderBuffer rob <- mkOboeReorderBuffer;
  OboeRegAliasTable rat <- mkOboeRegAliasTable;

  Wire#(Tag) to_free <- mkWire;

  // Implicit guard: ROB sends rename request.
  rule rl_rename;
    match {.rd, .tag} = rob.renameRequest();
    rat.rename(rd, tag);
    $display("[%d] rename %d -> %d", $time, rd, tag);
  endrule

  // Implicit guard: ROB sends commit request.
  rule rl_commit;
    match {.rd, .tag} = rob.commitRequest();
    // Assume can commit.
    Tag t <- rat.commit(rd, tag);
    to_free <= t;
    $display("[%d] commit %d -> %d, free %d", $time, rd, tag, t);
  endrule

  rule rl_commit_ack;
    rob.commitAck(to_free);
  endrule

  function Put#(Tuple2#(ArchRegId, Tag)) genWbPort(Integer i);
    let wb_port =
      (interface Put#(Tuple2#(ArchRegId, Tag));
        method Action put(Tuple2#(ArchRegId, Tag) rd_tag);
          match {.rd, .tag} = rd_tag;
          // Tell RAT that rd is no longer outdated.
          rat.wbPorts[i].put(rd);
          // Tell ROB that the data in the entry is ready.
          rob.wbPorts[i].put(tag);
        endmethod
      endinterface);
    return wb_port;
  endfunction

  interface Put renamePort;
    // Implicit guard: ROB is not full && Dispatcher is not full.
    method Action put(BackendInst inst);
      let entry = RobEntry {
        pc: inst.pc,
        rd: inst.rd,
        trap: inst.trap
      };
      rob.insert(entry);
      // dispatch queue insert
    endmethod
  endinterface

  interface Vector wbPorts = map(genWbPort, genVector);

endmodule

endpackage
