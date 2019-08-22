
import json, tables, jsffi, strutils, times

include karax / prelude
import karax / prelude
import karax / [vdom, karaxdsl, kdom]

import uuidjs

import builder, ui_utils, ui_def_gen, listeners, navigation, appcontext
export builder, ui_utils

import uielement, uibuild

import components / components
export components

var console {. importc, nodecl .}: JsObject

var
  initialized = false
  `kxi`: KaraxInstance
  prevHashPart: cstring
  ctxt: AppContext
  app: App
  customNav = false


proc reRender*()=
  # wrap and expose redraw
  `kxi`.redraw()
  # ctxt.state["_renderData"] = %*{}


proc eventGen*(uiev: uielement.UiEvent, el: UiElement, viewid: string): proc(ev: Event, n: VNode) =
  result = proc (ev: Event, n: VNode) =
    ev.preventDefault()
    
    let
      evt = ev.`type`
    
    var
      payload = %*{"value": %""}
      event = %*{"type": %($evt)}

    for k, v in n.attrs:
      if k == "model":
        payload["model"] = %($n.getAttr "model") #%model
      if k == "value":
        payload["value"] = %($n.getAttr "value")
      
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
          
    payload["node_kind"] = %($n.kind)
    payload["event_kind"] = %uiev.kind
    
    if n.getAttr("action") != nil:
      payload["action"] = %($n.getAttr "action")
      
    if n.getAttr("mode") != nil:
      payload["mode"] = %($n.getAttr "mode")
    
    if n.getAttr("name") != nil:
      payload["field"] = %($n.getAttr "name")

    if n.getAttr("field") != nil:
      payload["field"] = %($n.getAttr "field")
    
    if el.id != "":
      payload["objid"] = %el.id

    if not n.value.isNil and n.value != "":
      payload["value"] = %($n.value)
    
    if payload.haskey "action":
      payload = ctxt.navigate(ctxt, payload, viewid)
      callEventListener(payload, ctxt.actions)
      reRender()
      
    elif n.getAttr("eventhandler") != nil:
      payload["eventhandler"] = %($n.getAttr "eventhandler")
      callEventListener(payload, ctxt.actions)
      
      if customNav == true:
        payload = ctxt.navigate(ctxt, payload, viewid)
      
          
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


proc handleCreateDomException(): Vnode =
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


# uses app instead of ctxt
proc createAppDOM(rd: RouterData): VNode =
  setHashRoute(rd)
  try:
    if ctxt.state.hasKey("error"):
      result = showError()
      
    elif app.state == "ready":
      result = updateUI(app)
            
    elif app.state == "loading":
      echo "Loading..."
      result = buildHtml(tdiv()):
        p:
          text "Loading Site..."

      result = initApp(app, eventGen)
      app.state = "ready"
      
    else:
      # TODO: show invalid state error
      echo "App invalid state."
      
  except:
    result = handleCreateDomException()


# debug this code
proc createApp*(a: var App) =
  app = a
  ctxt = app.ctxt 
  initNavigation()
  ctxt.components = initComponents(ctxt.components)
  if ctxt.navigate.isNil:
    ctxt.navigate = navigate
  else:
    customNav = true
  `kxi` = setRenderer(createAppDOM)
