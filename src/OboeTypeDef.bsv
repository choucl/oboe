package OboeTypeDef;
import OboeConfig::*;
typedef 32                         XLEN;
typedef 32                         NumArchRegs;
Integer kNumArchRegs = valueOf(NumArchRegs);
typedef UInt#(TLog#(NumArchRegs))  ArchRegId;
typedef TLog#(NumPhysicalRegs)     TagWidth;
typedef UInt#(TagWidth)            Tag;
typedef Bit#(XLEN)                 Word;
endpackage
