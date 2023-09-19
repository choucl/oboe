package OboeTypeDef;
import OboeConfig::*;
typedef 32                         XLEN;
typedef 32                         NumRegs;
typedef UInt#(TLog#(NumRegs))      ArchRegId;
typedef TLog#(PhysicalRegFileSize) TagWidth;
typedef UInt#(TagWidth)            Tag;
typedef Bit#(XLEN)                 Word;
endpackage
