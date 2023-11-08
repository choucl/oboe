package OboeReorderBuffer;

import Vector::*;
import GetPut::*;
import Assert::*;

import StmtFSM::*;

import OboeTypeDef::*;
import OboeConfig::*;
import OboeFreeList::*;

// Typedef: RobEntry
//   Reorder buffer entry.
typedef struct {
  Word      pc;
  ArchRegId rd;
  Maybe#(TrapCause) trap;
} RobEntry deriving(Bits);

// Interface: OboeReorderBuffer
//   Scheduler uses the interface to control ROB.
interface OboeReorderBuffer;
  // Method: insert
  //   Insert an <BackendInst> into the ROB. Whether this method can be call depends on whether
  //   <OboeFreeList> is able to allocate an entry for the instruction.
  //
  // Parameter:
  //   entry - Instruction to insert into the ROB.
  method Action insert(RobEntry entry);
  // Method: renameRequest
  //   ROB issues a rename request from the ROB when the <BackendInst> coming in is valid and an
  //   entry is successfully allocated.
  //
  // Return:
  //   A Tuple2 of <ArchRegId> and <Tag> to rename the destination register to the tag.
  method Tuple2#(ArchRegId, Tag) renameRequest();
  // Subinterface: wbPorts
  //   A Vector of Put interface for write back request from execution units. EXU puts the <Tag> in
  //   the put method to indicate the corresponding instruction finishes execution.
  interface Vector#(NumWbPorts, Put#(Tag)) wbPorts;
  // Method: commitRequest
  //   ROB issues a commit request when the entry pointed by commit_ptr is valid and marked
  //   wb_ready. This request is forwarded to the <OboeRegAliasTable> by the scheduler to update the
  //   <OboeArchitectureRegMap>.
  //
  // Return:
  //   A Tuple2 of <ArchRegId> and <Tag> to commit the instruction.
  method Tuple2#(ArchRegId, Tag) commitRequest();
  // Method: commitAck
  //   The scheduler calls <commitAck> to acknowledge the commit request. Scheduler gives the <Tag>
  //   released by the <OboeArchitectureRegMap> to update <OboeFreeList>.
  //
  // Parameter:
  //   to_free - The entry released when commitment.
  method Action commitAck(Tag to_free);
endinterface

// Module: mkOboeReorderBuffer
//   You know what a reorder buffer is.
module mkOboeReorderBuffer (OboeReorderBuffer);
  // Object: freelist
  //   <OboeFreeList>
  OboeFreeList freelist <- mkOboeFreeList;
  // Object: entries
  //   Vector of <RobEntry>. The main memory storage of the ROB.
  Vector#(NumPhysicalRegs, Reg#(Maybe#(RobEntry))) entries <- replicateM(mkReg(Invalid));
  // Object: wb_ready
  //   Vector of registers of Bool. The registers are implemented using mkCReg with <kNumWbPorts> +
  //   1 Reg interfaces. This gives the write-back port with higher index a higher priority to avoid
  //   conflict. An extra interface is used by invalidation when commitment. Invalidation has the
  //   highest priority.
  Vector#(NumPhysicalRegs, Array#(Reg#(Bool))) wb_ready <-
      replicateM(mkCReg(kNumWbPorts + 1, False));

  // Wires to propagate the entry to write and to invalidate.
  Wire#(Tuple2#(Tag, RobEntry)) to_write <- mkWire;
  Wire#(Tag) to_invalidate <- mkWire;

  // Wires to propagate rename and commit request.
  Wire#(Tuple2#(ArchRegId, Tag)) rename_request <- mkWire;
  Wire#(Tuple2#(ArchRegId, Tag)) commit_request <- mkWire;

  // Object: commit_ptr
  //   Points to the entry to commit next. <OboeFreeList> gives the next position when commitment.
  Reg#(Tag) commit_ptr <- mkReg(fromInteger(kNumArchRegs));

  // Function: writeEntry
  //   Write the entry when insertion.
  //
  // Parameter:
  //   tag   - The entry to write.
  //   entry - The data used to write the entry.
  function Action writeEntry(Tag tag, RobEntry entry) =
    action
      to_write <= tuple2(tag, entry);
    endaction;

  // Function: invalidate
  //   Invalidate an entry and clear the wb_ready bit.
  //
  // Parameter:
  //   tag - The entry to invalidate.
  function Action invalidate(Tag tag) =
    action
      to_invalidate <= tag;
    endaction;

  // Try to commit the oldest instruction. Fires when the entry is valid and marked wb_ready.
  rule rl_gen_commit_request (
      entries[commit_ptr] matches tagged Valid .inst &&& wb_ready[commit_ptr][0]);
    commit_request <= tuple2(inst.rd, commit_ptr);
  endrule

  // Both rl_write_entry and rl_invalidate_entry writes to <entries>. The entries to be written must
  // be different.
  (* conflict_free="rl_write_entry,rl_invalidate_entry"*)
  rule rl_write_entry;
    match {.tag, .entry} = to_write;
    dynamicAssert(!isValid(entries[tag]), "ROB entry to write must be invalid");
    entries[tag] <= tagged Valid entry;
  endrule

  rule rl_invalidate_entry;
    dynamicAssert(isValid(entries[to_invalidate]), "ROB entry to invalidate must be valid");
    entries[to_invalidate] <= tagged Invalid;
    dynamicAssert(wb_ready[to_invalidate][0], "ROB entry to invalidate must be wb_ready");
    wb_ready[to_invalidate][kNumWbPorts] <= False;
  endrule

  // Function: genWbPort
  //   Function to generate a Put interface with index i.
  //
  // Parameter:
  //   i - Port index.
  //
  // Return:
  //   The Put interface at index i.
  function Put#(Tag) genWbPort(Integer i);
    let wb_port =
      (interface Put#(Tag);
        method Action put(Tag wb_tag);
          wb_ready[wb_tag][i] <= True;
        endmethod
      endinterface);
    return wb_port;
  endfunction

  method Action insert(RobEntry entry);
    // Try to allocate an entry for the inst.
    Tag free <- freelist.allocate();
    writeEntry(free, entry);
    // Send the rename request.
    rename_request <= tuple2(entry.rd, free);
  endmethod

  method Tuple2#(ArchRegId, Tag) renameRequest() = rename_request;

  interface Vector wbPorts = map(genWbPort, genVector);

  method Tuple2#(ArchRegId, Tag) commitRequest() = commit_request;

  method Action commitAck(Tag to_free);
    Tag commit_ptr_n <- freelist.commitAndFree(commit_ptr, to_free);
    invalidate(to_free);
    // Update the commit pointer by the new one given by freelist
    commit_ptr <= commit_ptr_n;
  endmethod

endmodule

endpackage
