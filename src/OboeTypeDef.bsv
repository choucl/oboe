package OboeTypeDef;

import OboeConfig::*;

// Typedef: XLEN
//   RISC-V XLEN.
typedef 32 XLEN;

// Typedef: NumArchRegs
//   Number of architectural registers.
typedef 32 NumArchRegs;

// Constant: kNumArchRegs
//   Integer value of <NumArchRegs>.
Integer kNumArchRegs = valueOf(NumArchRegs);

// Typedef: ArchRegId
//   Architectural register ID/specifier type.
typedef UInt#(TLog#(NumArchRegs)) ArchRegId;

// Typedef: TagWidth
//   Bit width of <Tag>.
typedef TLog#(NumPhysicalRegs) TagWidth;

// Typedef: Tag
//   Pointer to the physical register or ROB, used for renaming.
typedef UInt#(TagWidth) Tag;

// Typedef: Word
//   XLEN-width bit data.
typedef Bit#(XLEN) Word;

endpackage
