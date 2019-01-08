
import json, jsffi, tables, sequtils, strutils

import site_genpkg / utils

proc postMessage(d: JsObject) {. importc: "postMessage" .}

var
  console {.importcpp, noDecl.}: JsObject 
  log = console.log
  ui: JsonNode # global ui sate in memory
  data: JsonNode = %*{} # global data


# test data
var todoList = %[
  {
    "text": %"Use nim for front and backend",
    "completed": %true
  },
  {
    "text": %"Finish site gen library",
    "completed": %false
  }  
]

data.add("todos",todoList)

var editNameOnclick = proc (payload: JsonNode){.closure.} =
  let
    id = payload["id"].getStr
    value = payload["value"].getStr
  updateValue(ui, id, value)  


var
  gridRowOnClick = proc(payload: JsonNode){.closure.} =
    let id = payload["id"].getStr
    setAttribute(ui, id, "checked", "true")
    
  completeTodo = proc(payload: JsonNode){.closure.} =
    echo "todo completed"
 

# actions table
# actions are bonded to ui event handlers
# actions have the id of the component attached and con operate
# on ui components as well as its childs
var actions = initTable[cstring, seq[proc(payload: JsonNode){.closure.}]]()
actions.add(cstring"todo_name_onkeyup", @[editNameOnclick])
actions.add(cstring"todo_gridRow_onclick", @[gridRowOnClick])


# data listeners
# data listeners react to data changes 
var dataListeners = newseq[proc(payload: JsonNode){.closure.}]()
dataListeners.add(completeTodo)

proc callDataListeners(payload: JsonNode) =
  echo "should do something with data and ui"
  for dataListener in dataListeners:
    dataListener(payload)
  
proc callEventListener(payload: JsonNode, action: cstring) =
  if actions.hasKey(action):
    echo "calling action: " & action
    for eventListener in actions[action]:
      eventListener(payload)
  else:
    echo "WARNING: Action $1 not found in the table." % $action


var onmessage {.exportc.} = proc(d: JsObject) =
  let data = d["data"]
  ui = copy data["ui"].to(JsonNode)
  let
    action = data["action"].to(cstring)
    id = data["id"].to(string)
  if action == cstring"init":
    echo "--- initializing worker ---"
    
  else:
    var payload = %*{
      "id": %id
    }
    
    if data.value != nil:
      payload["value"] = %($data["value"].to(cstring))
    
    callEventListener(payload, action)
    callDataListeners(payload)
    
  var response = newJsObject()   
  response.ui = ui
  response.msg = cstring"OK"
  response.status = cint(200)
  response.id = id
  postMessage(response)
