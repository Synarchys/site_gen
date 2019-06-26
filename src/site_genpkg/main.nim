
import json, tables, jsffi, strutils, times

include karax / prelude
import karax / prelude
import karax / [vdom, karaxdsl, kdom]

import uuidjs

import builder, ui_utils, ui_def_gen, listeners, navigation, appContext
export builder, ui_utils

import components / components
export components

     
var
  initialized = false
  `kxi`: KaraxInstance
  prevHashPart: cstring
  ctxt: AppContext


proc reRender*()=
  # wrap and expose redraw
  `kxi`.redraw()


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

    if payload.haskey("type") and (payload["type"].getStr == "date" or
                                   payload["type"].getStr == "checkbox"):
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
        payload = ctxt.navigate(ctxt, payload, viewid)
            
    callEventListener(payload, ctxt.actions)    
    reRender()
      

proc setHashRoute(rd: RouterData) =
  if prevHashPart != $rd.hashPart:
    ctxt.state["route"] = %($rd.hashPart)
    prevHashPart = $rd.hashPart
  elif $prevHashPart != ctxt.state["route"].getStr:
    window.location.href = cstring(ctxt.state["route"].getStr)
    prevHashPart = window.location.hash  


proc showError(): VNode =
  result = buildHtml(tdiv(class="container-fluid")):
    tdiv(class="alert alert-danger",role="alert"):
      h3:
        text "Error:"
      p:
        text ctxt.state["error"].getStr
      a(href="#/home"):
        text "Go back home."
  ctxt.state.delete("error")
  reRender()


proc initNavigation() =
  ctxt.state["route"] = %($window.location.hash)
  prevHashPart = window.location.hash
  # init history
  let vid = genUUID()
  ctxt.state{"history", vid} = %*{"id": %vid, "action": ctxt.state["route"]}
  ctxt.state["view"] = %*{"id": %vid}

    
proc createDOM(rd: RouterData): VNode =
  setHashRoute(rd)
  try:
    if ctxt.state.hasKey("error"):
      result = showError()
      
    elif initialized:
      result = updateUI(ctxt)
      
    elif ctxt.state.isNil or not ctxt.state.hasKey("definition"):
      result = buildHtml(tdiv()):
        p:
          text "Loading Site..."
    else:
      let started = now()
      echo " -- Initializing $1 --" % $started.nanosecond
      result = initApp(ctxt, eventGen)
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
      msg = "Builder Error: Something went wrong."
    ctxt.state["error"] = %msg
    result = showError()
    

proc createApp*(appctxt: AppContext) =
  ctxt = appctxt
  initNavigation()
  ctxt.components = initComponents(ctxt.components)
  if ctxt.navigate.isNil: ctxt.navigate = navigate
  `kxi` = setRenderer(createDOM)


