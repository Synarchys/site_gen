
import json, jsffi, tables, sequtils, strutils
import site_genpkg / [ui_utils, worker_utils]
import jsonflow, uuidjs

# devel only
import macros

proc postMessage(d: JsObject) {. importc: "postMessage" .}

var
  console {.importcpp, noDecl.}: JsObject 
  log = console.log
  ui: JsonNode # global ui sate in memory
  store: JsonNode = %*{} # global data


# test data
var todoList = %[
  {
    "id": %($genUUID()),
    "text": %"Use nim for front and backend",
    "completed": %true
  },
  {
    "id": %($genUUID()),
    "text": %"Finish site gen library",
    "completed": %false
  }
]


store.add("id", %("todoList"))
store.add("todos", todoList)


var
  flowId = $genUUID()
  flow = createFlow(flowId)
  dataListeners = initTable[cstring, cstring]()


var
  editNamekeyUp = proc(payload: JsonNode){.closure.} =
    # event handlers
    # call rest services and modify status if needed
    let
      id = payload["id"].getStr
      value = payload["value"].getStr
    updateValue(ui, id, value)

  gridRowOnClick = proc(payload: JsonNode){.closure.} =
    # event handler
    let id = payload["id"].getStr
    # change the state
    flow.send(store, proc(d: JsonNode) = echo $d)

  renderMyGrid = proc(payload: JsonNode){.closure.} =
    # bonded to a ui-component
    # when data is modified react to it and update the ui-state
    let
      componentId = dataListeners["renderMyGrid"]
      component = getElementById(ui, $componentId)
    flow.seek("todoList", proc(e: JsonNode) =
      echo "--------------- value found in flow -----------------------"
      echo $e["todos"]
      echo component
      echo "-----------------------------------------------------------"
    )
    echo "add the logic to render this component when there's data"

# Actions are bonded to ui event handlers
# actions have the id of the component attached and can operate
# on ui components as well as its childs

dumpAstGen:
#   #var dataListeners = initTable[cstring, cstring]()
  var actions = initTable[cstring, proc(payload: JsonNode){.closure.}]()
  actions.add(cstring"todo_name_onkeyup", proc (payload: JsonNode) =
      echo payload)
#   actions.add(cstring"todo_gridRow_onclick", gridRowOnClick)

#let subsID = flow.subscribe(renderMyGrid)

# var
#   editNamekeyUp = proc(payload: JsonNode){.closure.} =
#     # event handlers
#     # call rest services and modify status if needed
#     let
#       id = payload["id"].getStr
#       value = payload["value"].getStr
#     updateValue(ui, id, value)

    
worker:
  # event handlers
  EventHandlers:
    proc todo_name_onkeyup(payload: JsonNode) =
      echo payload

    proc todo_gridRow_onclick(payload: JsonNode) =
      echo "processing event handler"


communication()
