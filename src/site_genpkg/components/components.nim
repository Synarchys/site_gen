
import tables, json

import ../ui_utils
import showmodel, listmodel, editmodel, datepicker, messages
export showmodel, listmodel, editmodel, datepicker, messages


proc initComponents*(c: Table[string, proc(ctxt: AppContext, uidef, payload: JsonNode): JsonNode] ):
                   Table[string, proc(ctxt: AppContext, uidef, payload: JsonNode): JsonNode] =

  result = initTable[string, proc(ctxt: AppContext, uidef, payload: JsonNode): JsonNode]()
  result["msg"] = UIMessages  
  result["edit"] = EditModel
  result["list"] = ListModel
  result["show"] = ShowModel
  
  for k, v in c.pairs:
    result[k] = v
