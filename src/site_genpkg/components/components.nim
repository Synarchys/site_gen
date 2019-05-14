
import tables, json

import uicomponent, showmodel, listmodel, editmodel, datepicker, messages
export uicomponent, showmodel, listmodel, editmodel, datepicker, messages


proc updateActions(bc: BaseComponent,
                   a: var Table[cstring, proc(payload: JsonNode){.closure.}]) =
  
  for name, handler in bc.actions.pairs:
    #echo "Updating actions"
    #if a.hasKey name: echo "WARNING: overrading handler: " & $name
    a[name] = handler


proc initComponents*(c: Table[string, BaseComponent],
                     a: var Table[cstring, proc(payload: JsonNode){.closure.}]):
                       Table[string, BaseComponent] =

  result = initTable[string, BaseComponent]()
  result["edit"] = newEditModel()
  result["list"] = newListModel()
  result["show"] = newShowModel()
  result["msg"]  = newMessages(a)

  #updateActions(result["msg"], a)
  
  for k, v in c.pairs:
    #echo "Adding component ", k
    result[k] = v
    updateActions(v, a)
    
