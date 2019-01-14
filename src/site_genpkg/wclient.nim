
# # Default client worker
# # it is used to dispatch an even when needed
# # this code is executed in the ui thread and invokes
# # the worker to perform the task.

# import json, jsffi, tables, strutils
# include karax / prelude

# import karax / [kdom, vdom]

# import utils

# var
#   console {.importcpp, noDecl.}: JsObject
#   log = console.log

# proc newWorker(f: cstring): JsObject {.importcpp: "new Worker(@)".}

# var w: JsObject = newWorker(cstring"/js/worker.js")

# #var message = cstring ""


# w.onmessage = proc(d: JsObject) =
#   ## This gets called when the worker sends a message
#   let response = d.data
#   log("UI --> Message from worker: ", response.msg.to(cstring))
#   echo response.status.to(cint)

#   let ui = response.ui.to(JsonNode)
#   echo componentId
#   # we've got the ui, now we have to update de vnode tree
#   # import builder
#   # updateUI(ui)
  
#   # elements events in karax trigger redraw
  

# w.onmessageerror = proc(d: JsObject) =
#   ## If something goes wrong, this will be called
#   log("in error: ", d)


# proc mainEvent*(appState: JsonNode, name, id: string): proc(ev: Event, n: VNode) =

#   result = proc (ev: Event, n: VNode) =
#     # handle manually
#     ev.preventDefault()
#     var data = newJsObject()
#     data["message"] = cstring"Somebody pressed a button on the UI"
#     data["action"] = cstring(name)
#     data["id"] = id
#     data["ui"] = appState["ui"]
#     w.postMessage(data)
    
