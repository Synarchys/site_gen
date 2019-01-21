
import json, tables, jsffi

include karax / prelude 
import karax / prelude
import karax / [vdom, karaxdsl, errors, kdom, vstyles]

import requestjs, uuidjs

import builder, ui_utils, listeners
export builder, ui_utils

import strutils, times

var console {.importcpp, noDecl.}: JsObject 

# global variables
const headers = [(cstring"Content-Type", cstring"application/json")]
const definitionUrl = "/definition.json"
const modelUrl = "/model.json"

var
  initialized = false
  `kxi`: KaraxInstance
  appStatus: JsonNode
  ui: JsonNode = %*{}
  actions: Table[cstring, proc(payload: JsonNode){.closure.}]


# TODO: move all loading to the worker
proc pareseJSonDefinion(resp: string): JsonNode = 
  try:
    result = parseJson($resp)
  except:
    # TODO: Show error component
    let msg = getCurrentExceptionMsg()
    appStatus["error"] = %msg
    echo "Error with message \n", msg

    
proc loadDefinition(appStatus: JsonNode) =
  ajaxGet(definitionUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appStatus["definition"] = pareseJSonDefinion($resp)
            # finally we redraw when we have everything loaded
            `kxi`.redraw()
  )

  
proc loadModel(appStatus: JsonNode) =
  ajaxGet(modelUrl,
          headers,
          proc(stat:int, resp:cstring) =
            if stat == 200:
              appStatus["model"] = pareseJSonDefinion($resp)
            loadDefinition(appStatus))

  
proc loadComponents(appStatus: JsonNode) =
  ajaxGet("/components.json",
          headers,
          proc(stat:int, resp:cstring) =
            let components = pareseJSonDefinion($resp)
            if appStatus.hasKey("components"):
              # merge components
              for k, v in components.getFields:
                if not appStatus["components"].hasKey(k):
                  # use components defined by the user if names colide
                  appStatus{"components", k}= v
            else:
              appStatus["components"] = components
            loadModel(appStatus))


proc eventGen*(action, id: string): proc(ev: Event, n: VNode) =    
  result = proc (ev: Event, n: VNode) =
    ev.preventDefault()
    
    var payload = %*{}
    payload["message"] = %"Somebody pressed a button on the UI"
    payload["ui"] = ui #appStatus["ui"] # pass the ui status, should be cached
    payload["action"] = %action # the name of the action that is triggered
    payload["id"] = %id # the id of the component
    if n.value != nil: payload["value"] = %($n.value)
    callEventListener(payload, action, actions)
    ui = payload["ui"]
    echo "New value is ", getValueById(ui, id)
    `kxi`.redraw()
    
    
proc createDOM(data: RouterData): VNode =  
  if initialized:
    result = updateUI(ui)
    ui = result.toJson
    
  elif appStatus.hasKey("error"):
    result = buildHtml(tdiv()):
      p:
        text appStatus["error"].getStr        
    appStatus.delete("error")
    
  elif not appStatus.hasKey("definition"):
    loadComponents(appStatus)
    result = buildHtml(tdiv()):
      p:
        text "Loading Site..."
  
  else:
    let started = now()
    echo " -- Initializing $1 --" % $started.nanosecond
    result = initApp(appStatus, eventGen)
    ui = result.toJson
    let ended = now()
    echo " -- Initialized $1 --" % $ended.nanosecond
    echo "Initialization time: $1 " % $(ended - started)
    initialized = true
          

proc createApp*(status: JsonNode,
                a: Table[cstring, proc(payload: JsonNode){.closure.}]) =
  actions = a
  appStatus = status
  `kxi` = setRenderer(createDOM)


