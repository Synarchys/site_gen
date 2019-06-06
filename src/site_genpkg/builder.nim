
import strutils, unicode

import json, tables, jsffi, sequtils
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import store, uuidjs
import components / uicomponent


var defaultEvent: proc(name, id, viewid: string): proc(ev: Event, n: VNode)

# global variable that holds all components
var
  appState, templates: JsonNode
var componentsTable: Table[string, proc(appSatus, uidef, data: JsonNode): JsonNode]

const ACTIONS = ["list", "show", "edit", "raw"]

type
  Sections = enum
    header, menu, body, footer
  
    
proc toJson*(component: VNode): JsonNode =
  ## returns a JsonNode from a VNode
  result = %*{ "ui-type": $component.kind }
             
  if component.getAttr("objid") != nil:
    result["id"] = %($component.getAttr("objid"))
   
  if component.class != nil: result["class"] = %($component.class)
  if component.text != nil or component.value != nil:
    if component.kind == VNodeKind.input:
      # `value` and `text` overlap on input componets
      result["value"] = %($component.value)
    else:
      result["text"] = %($component.text)

  var attributes = %*{}
  for k,v in component.attrs:
    attributes.add($k,%($v))
  if attributes.len > 0: result["attributes"] = attributes
                           
  var children = newJArray()
  for c in component.items:
    children.add(toJson(c))
  if children.len > 0: result["children"] = children
    
  var events = newJArray()
  for ev in component.events:
    events.add(%($ev[0]))
  if events.len > 0: result["events"] = events

    
proc updateValue(vn: var VNode, value: string) =
  # TODO: handle exceptions when de name of the model is not an object
  if vn.kind == VnodeKind.input:
    setInputText vn, value
      
          
proc buildComponent*(viewid: string, params: JsonNode): VNode =
  ## builds a component based on a json definition
  var nodeKind: VNodeKind

  for vnk in VNodeKind:
    if params.hasKey "ui-type":
      if $vnk == params["ui-type"].getStr:
        nodeKind = vnk
        break
    else:
      # TODO raise error.
      echo "Error: ui-type not defined or component not found."
      break

  if nodeKind == VNodeKind.text:
    # text kind has its own constructor
    result = text params["text"].getStr
  else:
    result = newVNode nodeKind

  if params.hasKey "id":
    result.setAttr "id", params["id"].getStr

  if params.hasKey "objid":
    result.setAttr "objid", params["objid"].getStr
    
  if nodeKind == VNodeKind.label and params.hasKey "text":
    result.add text params["text"].getStr
    
  if nodeKind == VNodeKind.form:
    result.addEventListener EventKind.onsubmit,
                              proc(ev: Event, n: Vnode) =
                                ev.preventDefault 
  if params.hasKey "class":
    result.class = params["class"].getStr

  if params.hasKey "attributes":
    for k, v in params["attributes"].fields:
      result.setAttr k, v.getStr

  if params.hasKey "model":
    result.setAttr "model", params["model"].getStr

  if params.hasKey "name":
    result.setAttr "name", params["name"].getStr
    
  if params.hasKey "action":
    result.setAttr "action", params["action"].getStr

  if params.hasKey "dataListener":
    result.setAttr "dataListener", params["dataListener"].getStr

  if params.hasKey "events":
    let events = params["events"]
    var id = if params.hasKey "objid": kstring(params["objid"].getStr)
             else: result.getAttr "id" # deprecate de use of `id`
    
    if id.isNil: id = ""
    if events.kind == JString:
      for evk in EventKind:
        if events.getStr == $evk:
          result.addEventListener evk, defaultEvent($evk, $id, viewid)
    elif events.kind == JArray:
      for evk in EventKind:
        if events.contains %($evk):
          result.addEventListener evk, defaultEvent($evk, $id, viewid)
    else:
      let comp = params["model"].getStr & "_" &  params["name"].getStr
      echo "$1 - Wrong defenition of events, should be a String or an Array." % comp
        
  # updateValue result
  if params.haskey "value": result.updateValue params["value"].getStr
    
  if params.hasKey "children":
    for child in params["children"].getElems:
      result.add buildComponent(viewid, child)


proc getModelList(ids: JsonNode): JsonNode {.deprecated: "use site_gen's instead".} =
  # helper proc that returns a list of entities
  result = %[]
  for objId in ids:
    result.add appState.getItem objId.getStr

    
proc buildHeader(def: JsonNode): VNode =
  var h = copy templates["header"]
  # WARNING: hardcoded
  h["children"][0]["children"][0]["children"][0]["children"][0]["children"][0]["text"] = def["alternative"]
  result = buildComponent(genUUID(), h)


proc ErrorPage(txt: string): JsonNode =
  result = %*{"ui-type":"div","class":"container-fluid",
       "children":[{"ui-type":"div","class":"alert alert-danger","attributes":{"role":"alert"},
                     "children":[{"ui-type":"h4",
                                   "children":[{"ui-type":"#text","text": txt}]},
                                 {"ui-type":"a","attributes":{"href":"#/home"},
                                   "children":[{"ui-type":"#text","text":"Go back home."}]}]}]}

    
proc buildBody(viewid, action: string, bodyDefinition, data: JsonNode): VNode =
  # builds the initial ui based on the definition and the componentsTable library
  # this part should understand and comply with the component definition specification  
  var def = bodyDefinition
  result = buildComponent(viewid, copy templates["container"])

  result.setAttr("viewid", viewid)
  
  if appState.hasKey "message":
    echo appState["message"]
    var
      data = appState["message"]
      msgCmpnt = componentsTable["msg"](appState, %*{}, data)
    # we've shown it, delete it from the state
    appState.delete "message"
    result.add buildComponent(viewid, msgCmpnt)

  if componentsTable.haskey action:
    # if componentsTable has `<model>` and action key show it
    var comp = componentsTable[action](appState, def, data)
    result.add buildComponent(viewid, comp)
    
  else:
    result.add buildComponent(viewid, bodyDefinition)


proc updateUIRaw*(state: JsonNode): VNode =
  # builds the vdom tree using the ui attribute
  result = buildComponent(genUUID(), state["ui"])

    
proc updateUI*(state: var JsonNode): VNode =
  var
    uiDef      = state["definition"]
    definition = uiDef
    view       = state["view"]
    viewid     = view["id"].getStr
    data       = state["_renderData"]
    route, action: string
    
  if appState.hasKey("route") and appState["route"].getStr != "":
    let splitRoute = appState["route"].getStr.split "/"
    # just asume first item is `#`.
    # use `#` in the ui definition to know it is a route.
    route = splitRoute[0..1].join "/"
    if splitRoute.len > 2: action = splitRoute[2]

  result = newVNode VnodeKind.tdiv
  for section in Sections:
    var sectionDef = copy uiDef[$section]
    case $section
    of "body":
      var
        routeSec: JsonNode
        b: VNode      
      if sectionDef.hasKey route:
        if action == "":
          # the first action is the default
          for a in ACTIONS:
            if sectionDef[route].hasKey a:
              action = a
              routeSec = sectionDef[route][a]
              break
        routeSec = sectionDef[route][action]
        if view.haskey "mode":
          routeSec["mode"] = view["mode"]
        b = buildBody(viewid, action, routeSec, data)
      else:
        b = buildComponent(genUUID(), ErrorPage("Error - " & route & " Page Not Found. "))

      result.add b
    of "header":
      result.add buildHeader sectionDef
    of "menu":
      var m = componentsTable["menu"](appState, sectionDef, data)
      result.add buildComponent(viewid, m)
    else:
      # try to build as template
      if componentsTable.hasKey $section:
        result.add buildComponent(viewid, templates[$section])

    
proc initApp*(state: var JsonNode,
              c: Table[string, proc(appSatus, uidef, data: JsonNode): JsonNode],
              event: proc(name, id, viewid: string): proc(ev: Event, n: VNode)): VNode =
  let definition = state["definition"]
  appState = state
  templates = state["templates"]
  componentsTable = c
  defaultEvent = event
  result = updateUI state

