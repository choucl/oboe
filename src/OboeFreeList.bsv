package OboeFreeList;

import Vector::*;
import Assert::*;

import OboeTypeDef::*;
import OboeConfig::*;

interface OboeFreeList;
  method ActionValue#(Tag) allocate();
  method ActionValue#(Tag) commit(Tag commit_ptr);
  method Action free(Tag tag);
endinterface

module mkOboeFreeList (OboeFreeList);
  // Entries from 0 ~ (kNumArchRegs - 1) are allocated to the architectural registers by default.
  // Therefore the free list starts from kNumArchRegs to (kNumPhysicalRegs - 1) with values points
  // to the next entry.
  function Tag genInitialValue(Integer i) =
    (i >= kNumArchRegs && i < kNumPhysicalRegs - 1) ? fromInteger(i + 1) : 0;

  // Vector of registers for the free list
  Vector#(NumPhysicalRegs, Reg#(Tag)) next <- mapM(mkReg, map(genInitialValue, genVector));

  // Free pointer initially points to the first entry
  Reg#(Tag) free_ptr <- mkReg(fromInteger(kNumArchRegs));

  // Null pointer initially points to the last entry
  Reg#(Tag) null_ptr <- mkReg(fromInteger(kNumPhysicalRegs - 1));

  Bool is_full = free_ptr == null_ptr;

  method ActionValue#(Tag) allocate() if (!is_full);
    // Advance the free pointer
    free_ptr <= next[free_ptr];
    // Return the free pointer as the allocated entry
    return free_ptr;
  endmethod

  method ActionValue#(Tag) commit(Tag commit_ptr);
    // Set the committed entry to 0
    next[commit_ptr] <= 0;
    // Return the next entry to commit
    return next[commit_ptr];
  endmethod

  method Action free(Tag tag);
    dynamicAssert(next[tag] == 0, "Cannot free an in-use entry");
    // Append the entry to the list
    next[null_ptr] <= tag;
    // Relocate the null pointer
    null_ptr <= tag;
  endmethod
  
endmodule

module mkOboeFreeListTest ();
  OboeFreeList freelist <- mkOboeFreeList();

  Reg#(int) a <- mkReg(0);
  rule check;
    if (a == 3) $finish;
    else a <= a + 1;
  endrule

endmodule

endpackage
