
import json, jsffi, tables, sequtils, strutils
import site_genpkg / [ui_utils, worker_utils]
import jsonflow, uuidjs


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


store.add("id", %($genUUID()))
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
    echo component
    # flow.seek("1", proc(e: JsonNode) =
    #   echo "--------------- value found in flow -----------------------"
    #   echo $e
    #   echo "-----------------------------------------------------------"
    # )
    echo "add the logic to render this component when there's data"
  

# Actions are bonded to ui event handlers
# actions have the id of the component attached and can operate
# on ui components as well as its childs
var actions = initTable[cstring, seq[proc(payload: JsonNode){.closure.}]]()
actions.add(cstring"todo_name_onkeyup", @[editNameKeyUp])
actions.add(cstring"todo_gridRow_onclick", @[gridRowOnClick])

let subsID = flow.subscribe(renderMyGrid)


worker(dataListeners, actions)
