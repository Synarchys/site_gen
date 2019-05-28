
import json, tables, jsffi, strutils, times

include karax / prelude 
import karax / prelude
import karax / [vdom, karaxdsl, errors, kdom, vstyles]

import uuidjs

import builder, ui_utils, ui_def_gen, listeners
export builder, ui_utils

import components / components
export components

var console {.importcpp, noDecl.}: JsObject 

# global variables
const
  HEADERS        = [(cstring"Content-Type", cstring"application/json")]
  TEMPLATES_URL  = "/templates.json"
  DEFINITION_URL = "/definition.json"
  MODEL_URL      = "/auto/schema" #"/model.json"
  

var
  initialized = false
  `kxi`: KaraxInstance
  appState: JsonNode
  prevHashPart: cstring
  actions: Table[cstring, proc(payload: JsonNode){.closure.}]
  componentsTable: Table[string, proc(appSatus, uidef, payload: JsonNode): JsonNode]
  history = %*{}
  #dataListeners: Table[cstring, cstring]

proc updateData(n: VNode){.deprecated.} =
  if not n.value.isNil:
    let 
      model = $n.getAttr "model"
      field = $n.getAttr "name"
    if not appState.hasKey("data"):
      appState.add("data", %*{})
    if not appState["data"].hasKey(model):
      appState["data"].add(model, %*{})
    # update the value
    appState["data"][model].add($field, %($n.value))

  
proc reRender*()=
  # wrap and expose redraw
  `kxi`.redraw()


proc newView(action, model, sourceId: string, payload: JsonNode):JSonNode =
  result  = %*{
    "id": %genUUID(),
    "action": %action,
    "model": %model,
    "source": %sourceid,
    "payload": payload
  }


proc navigate(viewid: string, payload: JsonNode): JsonNode =
  # `viewid` is where the actions come from
  # if we are going to show an action+model that does not exists
  #   create a new viewid and its navigations status and add it to the history
  # if it already exists, show it.

  # Types of Actions
  # there are two kinds of actions.
  # - singular: show, edit, add, list(singular mode)
  #     do not depend on anything. go back to previous `viewid`.
  # - dependant:  save, select, done, cancel.
  #     are attached to a previous `viewid` and the behaivor is determined by the parent `viewid`.
  result = payload
        
  var
    model = payload["model"].getStr
    action = payload["action"].getStr
    sourceView = history[viewid]
    targetView: JsonNode
      
  case action
  of "save", "select", "done", "cancel":
    targetView = history[sourceView["source"].getStr]

    if not targetView.haskey "model":
      # we are showing a msg o generic view, go to listing model.
      targetView = newView("list", model, sourceView["id"].getStr, payload)
      
    if action == "done":
      # goes to prevous viewid, changes should be persisted.
      action = targetView["action"].getStr
      result["action"] = %action
    
  of "delete":
    # do not redirect
    targetView = sourceView
    if (targetView.haskey "payload") and (targetView["payload"].haskey "objid"):
      result["parent"] = targetView["payload"]["objid"]
    
  of "new", "show","edit", "list", "add":
    if action == "add":
      action = "list"
      # result["mode"] = %"add"
      result["action"] = %action
      
    if action == "new":
      action = "edit"
      result["action"] = %action
      result["mode"] = %"new"
    
    targetView = newView(action, model, sourceView["id"].getStr, payload)

  else:
    # show the same 
    targetView = sourceView
    
  # add the entity id as parent of the current
  if (targetView.haskey "payload") and (targetView["payload"].haskey "objid"):
    result["parent"] = targetView["payload"]["objid"]
  
  history[targetView["id"].getStr] = targetView
  appState["viewid"] = targetView["id"]
  
  let route = "#/$1/$2" % [targetView["model"].getStr, targetView["action"].getStr]
  appState["route"] = %route
  

proc eventGen*(eventKind: string, id: string = "", viewid: string): proc(ev: Event, n: VNode) =
  result = proc (ev: Event, n: VNode) =
    let
      evt = ev.`type`
      model = $n.getAttr "model"
      
    var
      payload = %*{"value": %""}
      event = %*{"type": %($evt)}

    # TODO: improve event data passed.
    if not evt.isNil and evt.contains "key":
      event["keyCode"] = %(cast[KeyboardEvent](ev).keyCode)
      event["key"] = %($cast[KeyboardEvent](ev).key)
 
    payload["event"] = event
    if n.kind == VnodeKind.input:
      payload["type"] = %($n.getAttr "type")
    
    if payload.haskey("type") and payload["type"].getStr == "date":
      # let the dom handle the events for the `input date`
      discard
    else:
      ev.preventDefault()
    
    payload["model"] = %model
    payload["node_kind"] = %($n.kind)
    payload["event_kind"] = %eventKind
    
    if n.getAttr("action") != nil:
      payload["action"] = %($n.getAttr "action")

    if n.getAttr("mode") != nil:
      payload["mode"] = %($n.getAttr "mode")
    
    if n.getAttr("name") != nil:
      payload["node_name"] = %($n.getAttr "name")
    
    if id != "":
      payload["id"] = %id # deprecate de use of `id`  
      payload["objid"] = %id

    if not n.value.isNil:
      payload["value"] = %($n.value)
    
    if payload.haskey "action":
      payload = navigate(viewid, payload)
      
    callEventListener(payload, actions)    
    reRender()
      

proc setHashRoute(rd: RouterData) =
  if prevHashPart != $rd.hashPart:
    appState["route"] = %($rd.hashPart)
    prevHashPart = $rd.hashPart
  elif $prevHashPart != appState["route"].getStr:
    window.location.href = cstring(appState["route"].getStr)
    prevHashPart = window.location.hash  


proc showError(): VNode =
  result = buildHtml(tdiv(class="container-fluid")):
    tdiv(class="alert alert-danger",role="alert"):
      h3:
        text "Error:"
      p:
        text appState["error"].getStr
      a(href="#/home"):
        text "Go back home."
  reRender()
  appState.delete("error")
  
    
proc initNavigation() =
  appState["route"] = %($window.location.hash)
  prevHashPart = window.location.hash
  # init history
  let vid = genUUID()
  history[vid] = %*{"id": %vid, "action": appState["route"]}
  appState["viewid"] = %vid

    
proc createDOM(rd: RouterData): VNode =
  setHashRoute(rd)
  try:
    if appState.hasKey("error"):
      result = showError()
      
    elif initialized:
      result = updateUI(appState)
      
    elif not appState.hasKey("definition"):
      result = buildHtml(tdiv()):
        p:
          text "Loading Site..."
    else:
      let started = now()
      echo " -- Initializing $1 --" % $started.nanosecond
      result = initApp(appState, componentsTable, eventGen)
      let ended = now()
      echo " -- Initialized $1 --" % $ended.nanosecond
      echo "Initialization time: $1 " % $(ended - started)
      initialized = true
      
  except:
    let e = getCurrentException()
    var msg: string
    if not e.isNil:
      msg = e.getStackTrace()
      echo("===================================== ERROR ===================================")
      echo getCurrentExceptionMsg()
      echo(msg)
      echo("================================================================================")
    else:
      msg = "Builder Error: Somthing went wrong."
    appState["error"] = %msg
    result = showError()
    


proc createApp*(state: JsonNode,
                c: Table[string, proc(appSatus, uidef, payload: JsonNode): JsonNode],
                a: Table[cstring, proc(payload: JsonNode){.closure.}]) =
  actions = a
  actions["render"] = proc (payload: JsonNode) = reRender()
  appState = state
  initNavigation()
  componentsTable = initComponents(c, actions)
  `kxi` = setRenderer(createDOM)
