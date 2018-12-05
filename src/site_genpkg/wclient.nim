
# Default client worker
# it is used to dispatch an even when needed
# this code is executed in the ui thread and invokes
# the worker to perform the task.

import json, jsffi, tables
include karax / prelude

import karax / [kdom, vdom]

var
  console {.importcpp, noDecl.}: JsObject
  log = console.log

proc newWorker(f: cstring): JsObject {.importcpp: "new Worker(@)".}

var w: JsObject = newWorker(cstring"/js/worker.js")

proc editNameOnclick(payload: JsonNode) =
  echo "change the name of the on click"
  echo "modify the state, update dom graph and respond"


template cs(s: string): cstring =
  cstring(s)

# var edit = newJsObject()
# edit[cs"name_onclick"] = editNameOnclick
  
var actions: Table[cstring, proc(payload: JsonNode)] = initTable[cstring, proc(payload: JsonNode)]()
actions.add(cs"todo_gridRow_onclick", editNameOnclick)


var message = cstring ""
w.onmessage = proc(d: JsObject) =
  ## This gets called when the worker sends a message
  # log("UI --> Message from worker: ", d.data.to(cstring))
  message = d.data.to(cstring)
  ## After we update the state, we redraw the interface
  #kxi.redraw()

w.onmessageerror = proc(d: JsObject) =
  ## If something goes wrong, this will be called
  log("in error: ", d)


proc defaultEvent*(appState: JsonNode, name: string): proc(ev: Event, n: VNode) =
  result = proc (ev: Event, n: VNode) =
    if actions.hasKey(name):
      echo name
      actions[cs(name)](appState)
    
    # if prevent default is added inputs are not updated
    #ev.preventDefault()
    # var data = newJsObject()
    # data["message"] = cstring"Somebody pressed a button on the UI"
    # w.postMessage(data)
  
## END WORKER EXPERIMENT PART ##
