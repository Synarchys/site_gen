
import json, tables, jsffi
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs, uuidjs

import builder, utils
export builder, utils

import strutils, times

# worker wrapper
proc newWorker(f: cstring): JsObject {.importcpp: "new Worker(@)".}

var
  console {.importcpp, noDecl.}: JsObject 
  log = console.log

# global variables
const headers = [(cstring"Content-Type", cstring"application/json")]
const definitionUrl = "/definition.json"
const modelUrl = "/model.json"

var
  initialized = false
  myRenderer: proc (data: RouterData)
  w: JsObject = newWorker(cstring"/js/worker.js")
  `kxi`: KaraxInstance
  appStatus: JsonNode

# TODO: move all loading to the worker
proc loadDefinition(appStatus: JsonNode) =
  ajaxGet(definitionUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appStatus["definition"] = parseJson($resp)
            # finally we redraw when we have everything loaded
            `kxi`.redraw()
  )

  
proc loadModel(appStatus: JsonNode) =
  ajaxGet(modelUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appStatus["model"] = parseJson($resp)
            loadDefinition(appStatus))

  
proc loadComponents(appStatus: JsonNode) =
  ajaxGet("/components.json",
          headers,
          proc(stat:int, resp:cstring) =
            let components = parseJson($resp)
            if appStatus.hasKey("components"):
              # merge components
              for k, v in components.getFields:
                if not appStatus["components"].hasKey(k):
                  # use components defined by the user if names colide
                  appStatus{"components", k}= v
            else:
              appStatus["components"] = components
            loadModel(appStatus))

  
proc eventGen*(appStatus: JsonNode, name, id: string): proc(ev: Event, n: VNode) =  
  result = proc (ev: Event, n: VNode) =
    ev.preventDefault()
    var reqObj = newJsObject()
    reqObj["message"] = cstring"Somebody pressed a button on the UI"
    reqObj["ui"] = appStatus["ui"] # pass the ui status, should be cached 
    reqObj["action"] = cstring(name) # the name of the action that is triggered
    reqObj["id"] = id # the id of the component
    
    if n.value != nil: reqObj["value"] = n.value
    # send data to the worker
    w.postMessage(reqObj)


proc initWorker() =
  var reqObj = newJsObject()
  reqObj["ui"] = appStatus["ui"] # pass the ui status, should be cached 
  reqObj["action"] = cstring("init") # the name of the action that is triggered
  # send data to the worker
  w.postMessage(reqObj)


proc intialize() =
  # initialize ui
  w.onmessage = proc(d: JsObject) =
    ## This gets called when the worker sends a message
    let
      response = d.data
      id = response["id"].to(string)
      
    var ui = response["ui"].to(JsonNode)  
    appStatus["ui"] = ui
    `kxi`.redraw()

  w.onmessageerror = proc(d: JsObject) =
    ## If something goes wrong, this will be called
    log("in error: ", d)
  
  # initialize worker
  initWorker()

proc createDOM(data: RouterData): VNode =
  if initialized:
    result = updateUI(appStatus)
    appStatus["ui"] = result.toJson
    
  elif not appStatus.hasKey("definition"):
    result = buildHtml(tdiv()):
      p:
        text "Loading Site..."
  else:
    let started = now()
    echo " -- Initializing $1 --" % $started.nanosecond
    result = initApp(appStatus, eventGen)
    appStatus["ui"] = result.toJson
    # worker client intialization
    intialize()
    
    initialized = true
    let ended = now()
    echo " -- Initialized $1 --" % $ended.nanosecond
    echo "Initialization time: $1 " % $(ended - started)


proc createApp*(status:JsonNode) =
  appStatus = status
  loadComponents(appStatus)
  `kxi` = setRenderer(createDOM)
