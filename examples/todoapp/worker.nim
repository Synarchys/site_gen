
import json, jsffi, tables

proc postMessage(d: JsObject) {. importc: "postMessage" .}

var
  console {.importcpp, noDecl.}: JsObject 
  log = console.log
  
proc editNameOnclick(payload: JsonNode) =
  echo payload
  
var actions = initTable[cstring, proc(payload: JsonNode)]()
actions.add(cstring"todo_gridRow_onclick", editNameOnclick)

var onmessage {.exportc.} =  proc(d: JsObject)  =
  var state = d["data"]["state"].to(JsonNode)
  let action = d["data"]["action"].to(cstring)

  if actions.hasKey(action):
      actions[action](state)
      
  var data = newJsObject()
  data.msg = cstring"OK"
  data.status = cint(200)
  postMessage(data)
