
import tables, json

import uicomponent, showmodel, listmodel, editmodel, datepicker, messages
export uicomponent, showmodel, listmodel, editmodel, datepicker, messages


proc initComponents*(c: Table[string, proc(appSatus, uidef, payload: JsonNode): JsonNode],
                     a: var Table[cstring, proc(payload: JsonNode){.closure.}]):
                       Table[string, proc(appSatus, uidef, payload: JsonNode): JsonNode] =

  result = initTable[string, proc(appSatus, uidef, payload: JsonNode): JsonNode]()
  result["msg"] = UIMessages  
  result["edit"] = EditModel
  result["list"] = ListModel
  result["show"] = ShowModel
  
  for k, v in c.pairs:
    result[k] = v
    
    
    
