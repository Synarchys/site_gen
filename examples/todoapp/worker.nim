
import json, jsffi, tables, sequtils, strutils
import site_genpkg / [ui_utils, worker_utils]
import jsonflow, uuidjs


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


proc renderMyGrid(payload: JsonNode) =
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

    
let subsID = flow.subscribe(renderMyGrid)

worker:
  # event handlers
  EventHandlers:
    proc todo_name_onkeyup(payload: JsonNode) =
      let
        id = payload["id"].getStr
        value = payload["value"].getStr
        
      echo getValueById(ui, id)
      #updateValue(ui, id, value)

    proc todo_gridRow_onclick(payload: JsonNode) =
      echo "processing event handler"
      # event handler
      let id = payload["id"].getStr
      # change the state
      flow.send(store, proc(d: JsonNode) = echo $d)
