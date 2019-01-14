
import json, jsffi, tables, sequtils, strutils
import site_genpkg / ui_utils
import jsonflow, uuidjs


proc bindDataListners(ui: JsonNode, dataListeners: var Table[cstring, cstring]) =
  # bind procs that modify the ui state when data is changed
  # find components that have data listeners
  const key = "dataListeners"
  let elems = findElementsByAttrKey(ui, key)
  for elem in elems:
    let
      listener = elem["attributes"][key].getStr
      id = elem["id"].getStr
    dataListeners.add(listener, id)


proc callEventListener(payload: JsonNode, action: cstring,
                       actions: Table[cstring, seq[proc(payload: JsonNode){.closure.}]]) =
  if actions.hasKey(action):
    for eventListener in actions[action]:
      eventListener(payload)
  else:
    echo "WARNING: Action $1 not found in the table." % $action


template worker*(dataListeners: Table[cstring, cstring],
                 actions: Table[cstring, seq[proc(payload: JsonNode){.closure.}]]) =
  
  var onmessage* {.exportc.} = proc(d: JsObject) =
    let
      data = d["data"]
      action = data["action"].to(cstring)
      id = data["id"].to(string)
    ui = copy data["ui"].to(JsonNode)
    
    if action == cstring"init":
      echo "--- initializing worker ---"
      bindDataListners(ui, dataListeners)
    else:
      var payload = %*{
        "id": %id
      }
      if data.value != nil:
        payload["value"] = %($data["value"].to(cstring))    
      callEventListener(payload, action, actions)
    
      var response = newJsObject()
      response.ui = ui
      response.msg = cstring"OK"
      response.status = cint(200)
      response.id = id
      postMessage(response)
