
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
  appState: JsonNode
  actions: Table[cstring, proc(payload: JsonNode){.closure.}]
  dataListeners: Table[cstring, cstring]

# TODO: move all loading to the worker
proc pareseJSonDefinion(resp: string): JsonNode = 
  try:
    result = parseJson($resp)
  except:
    # TODO: Show error component
    let msg = getCurrentExceptionMsg()
    appState["error"] = %msg
    echo "Error with message \n", msg

    
proc loadDefinition(appState: JsonNode) =
  ajaxGet(definitionUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appState["definition"] = pareseJSonDefinion($resp)
            # finally we redraw when we have everything loaded
            `kxi`.redraw()
  )

  
proc loadModel(appState: JsonNode) =
  ajaxGet(modelUrl,
          headers,
          proc(stat:int, resp:cstring) =
            if stat == 200:
              appState["model"] = pareseJSonDefinion($resp)
            loadDefinition(appState))

  
proc loadComponents(appState: JsonNode) =
  ajaxGet("/components.json",
          headers,
          proc(stat:int, resp:cstring) =
            let components = pareseJSonDefinion($resp)
            if appState.hasKey("components"):
              # merge components
              for k, v in components.getFields:
                if not appState["components"].hasKey(k):
                  # use components defined by the user if names colide
                  appState{"components", k}= v
            else:
              appState["components"] = components
            loadModel(appState))


proc updateInput(payload: JsonNode) =
  # deprecate (?)
  # sync with the vnode
  let
    id = payload["id"].getStr
    value = payload["value"].getStr    
  var ui = payload["ui"]
  updateValue(ui, id, value)
  payload["ui"] = ui


proc updateData(n: VNode) =
  if not n.value.isNil:
    let 
      model = $n.getAttr("model")
      field = $n.getAttr("name")
    
    if not appState.hasKey("data"):
      appState.add("data", %*{})
    if not appState["data"].hasKey(model):
      appState["data"].add(model, %*{})
    # update the value
    appState["data"][model].add($field, %($n.value))

  
proc reRender*()=
  `kxi`.redraw()

    
proc eventGen*(action, id: string): proc(ev: Event, n: VNode) =  
  result = proc (ev: Event, n: VNode) =
    ev.preventDefault()
    var payload = %*{}
    payload["ui"] = appState["ui"] # pass the ui status, should be cached
    payload["action"] = %action # the name of the action that is triggered
    # ignoring the id of the vnode, use component_id for internal reference
    #payload["id"] = %id # the id of the component
    if n.value != nil:
      payload["value"] = %($n.value)    
    callEventListener(payload, action, actions)
    appState["ui"] = payload["ui"]
    updateData(n)  
    reRender()
  

proc bindDataListeners() =
  # binds a ui component id to a proc  
  appState.add("dataListeners", %*{})
  for component in findElementsByAttrKey(appState["ui"], "dataListener"):
    let dl = component["attributes"]["dataListener"]
    appState["dataListeners"].add(dl.getStr, component["id"])


proc createDOM(rd: RouterData): VNode =  
  if appState.hasKey("route") and rd.hashPart != appState["route"].getStr:
      window.location.href = cstring(appState["route"].getStr)
      echo "route is ", appState["route"]
  else:
    # we store the current route
    appState["route"] = %($rd.hashPart)
    
  if appState.hasKey("error"):
    result = buildHtml(tdiv()):
      p:
        text appState["error"].getStr        
    appState.delete("error")
    
  elif initialized:
    result = updateUI(appState)
    appState["ui"] = result.toJson
    
  elif not appState.hasKey("definition"):
    loadComponents(appState)
    result = buildHtml(tdiv()):
      p:
        text "Loading Site..."

  else:
    let started = now()
    echo " -- Initializing $1 --" % $started.nanosecond
    result = initApp(appState, eventGen)
    appState["ui"] = result.toJson
    bindDataListeners()
    let ended = now()
    echo " -- Initialized $1 --" % $ended.nanosecond
    echo "Initialization time: $1 " % $(ended - started)
    initialized = true
    

proc createApp*(state: JsonNode,
                a: Table[cstring, proc(payload: JsonNode){.closure.}]) =
  actions = a
  appState = state
  `kxi` = setRenderer(createDOM)

