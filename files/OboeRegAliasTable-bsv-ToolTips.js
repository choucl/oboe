﻿NDContentPage.OnToolTipsLoaded({1:"<div class=\"NDToolTip TStruct LBluespecSystemVerilog\"><div class=\"TTSummary\">Entry for future register map.</div></div>",4:"<div class=\"NDToolTip TMethod LBluespecSystemVerilog\"><div id=\"NDPrototype4\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"4\" data-NarrowColumnCount=\"3\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/4\" style=\"grid-area:1/1/2/2\">method RegMapEntry lookup(</div><div class=\"PType InFirstParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">ArchRegId&nbsp;</div><div class=\"PName InLastParameterColumn\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"2/2/3/3\" style=\"grid-area:1/3/2/4\">index</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/4/2/5\" data-NarrowGridArea=\"3/1/4/4\" style=\"grid-area:1/4/2/5\">)</div></div></div></div><div class=\"TTSummary\">Lookup the tag for physical register file in future register map.</div></div>",5:"<div class=\"NDToolTip TMethod LBluespecSystemVerilog\"><div id=\"NDPrototype5\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"4\" data-NarrowColumnCount=\"3\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/3/2\" data-NarrowGridArea=\"1/1/2/4\" style=\"grid-area:1/1/3/2\">method Action rename(</div><div class=\"PType InFirstParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">ArchRegId&nbsp;</div><div class=\"PName InLastParameterColumn\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"2/2/3/3\" style=\"grid-area:1/3/2/4\">rd,</div><div class=\"PType InFirstParameterColumn\" data-WideGridArea=\"2/2/3/3\" data-NarrowGridArea=\"3/1/4/2\" style=\"grid-area:2/2/3/3\">Tag&nbsp;</div><div class=\"PName InLastParameterColumn\" data-WideGridArea=\"2/3/3/4\" data-NarrowGridArea=\"3/2/4/3\" style=\"grid-area:2/3/3/4\">tag</div><div class=\"PAfterParameters\" data-WideGridArea=\"2/4/3/5\" data-NarrowGridArea=\"4/1/5/4\" style=\"grid-area:2/4/3/5\">)</div></div></div></div><div class=\"TTSummary\">Rename the future register map entry with the given tag.</div></div>",7:"<div class=\"NDToolTip TClass LBluespecSystemVerilog\"><div id=\"NDPrototype7\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/2/2\">module mkOboeFutureRegMap(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">OboeFutureRegMap</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"3/1/4/3\" style=\"grid-area:1/3/2/4\">)</div></div></div></div><div class=\"TTSummary\">The future register map is in charge of maintaining the renamed tags. The module contains two vectors: tag_vector and outdated_vector. The combination of the two is the future register map.</div></div>",36:"<div class=\"NDToolTip TMethod LBluespecSystemVerilog\"><div id=\"NDPrototype36\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/2/2\">method ActionValue#(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">Tag</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"3/1/4/3\" style=\"grid-area:1/3/2/4\">) commit(ArchRegId rd, Tag commit_ptr)</div></div></div></div><div class=\"TTSummary\">Update the tag in architectural register map and return the old tag.&nbsp; When rd = 0, return the commit_ptr directly.</div></div>",38:"<div class=\"NDToolTip TClass LBluespecSystemVerilog\"><div id=\"NDPrototype38\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/2/2\">module mkOboeArchitectureRegMap(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">OboeArchitectureRegMap</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"3/1/4/3\" style=\"grid-area:1/3/2/4\">)</div></div></div></div><div class=\"TTSummary\">The architecture register map is in charge of maintaining the architectural state of all the logical registers. Logical registers map to the physical registers by looking up the tag_vector. tag_vector is forwarded to the mkOboeFutureRegMap when restoring.</div></div>",53:"<div class=\"NDToolTip TType LBluespecSystemVerilog\"><div id=\"NDPrototype53\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"5\" data-NarrowColumnCount=\"4\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/5\" style=\"grid-area:1/1/2/2\"><span class=\"SHKeyword\">typedef</span> UInt#(</div><div class=\"PType InFirstParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">TLog</div><div class=\"PSymbols\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"2/2/3/3\" style=\"grid-area:1/3/2/4\">#(</div><div class=\"PName InLastParameterColumn\" data-WideGridArea=\"1/4/2/5\" data-NarrowGridArea=\"2/3/3/4\" style=\"grid-area:1/4/2/5\">NumArchRegs)</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/5/2/6\" data-NarrowGridArea=\"3/1/4/5\" style=\"grid-area:1/5/2/6\">) ArchRegId</div></div></div></div><div class=\"TTSummary\">Architectural register ID/specifier type.</div></div>",64:"<div class=\"NDToolTip TType LBluespecSystemVerilog\"><div id=\"NDPrototype64\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/2/2\"><span class=\"SHKeyword\">typedef</span> UInt#(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">TagWidth</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"3/1/4/3\" style=\"grid-area:1/3/2/4\">) Tag</div></div></div></div><div class=\"TTSummary\">Pointer to the physical register or ROB, used for renaming.</div></div>"});