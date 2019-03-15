
import strutils, unicode

import json, tables, jsffi, sequtils
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import store, uuidjs
import components / [showmodel, listmodel, editmodel, datepicker]


var defaultEvent: proc(name, id: string): proc(ev: Event, n: VNode)

# global variable that holds all components
var appState, components: JsonNode

type
  Sections = enum
    header, menu, body, footer


# ui components
var
  dp = newDatePicker()
  em = newEditModel()
  lm = newListModel()
  sm = newShowModel()
    
proc toJson*(component: VNode): JsonNode =
  ## returns a JsonNode from a VNode
  result = %*{ "ui-type": $component.kind }
             
  # if component.getAttr("compnent_id") != nil:
  #   result["component_id"] = %($component.getAttr("compnent_id"))
  # else:
  #   result["component_id"] = %genUUID()
  
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
      
          
proc buildComponent*(params: JsonNode): VNode =
  ## builds a component based on a json definition
  var nodeKind: VNodeKind

  for vnk in VNodeKind:
    if params.hasKey "ui-type":
      if $vnk == params["ui-type"].getStr:
        nodeKind = vnk
        break
    else:
      # TODO raise error.
      echo "Error: component not found"
      break

  if nodeKind == VNodeKind.text:
    # text kind has its own constructor
    result = text params["text"].getStr
  else:
    result = newVNode nodeKind

  if params.hasKey "id":
    result.setAttr "id", params["id"].getStr
  # else:
  #   result.setAttr "id", genUUID 
  
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

  if params.hasKey "dataListener":
    result.setAttr "dataListener", params["dataListener"].getStr
  
  if params.hasKey "events":
    let events = params["events"]
    for evk in EventKind:
      if events.contains %($evk):
        var id = result.getAttr "id"
        if id.isNil: id = ""
        result.addEventListener evk, defaultEvent($evk, $id)
        
  # updateValue result
  if params.haskey "value": result.updateValue params["value"].getStr
    
  if params.hasKey "children":
    for child in params["children"].getElems:
      result.add buildComponent child
  

proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true


proc getModelList(ids: JsonNode): JsonNode =
  # helper proc that returns a list of entities
  result = %[]
  for objId in ids:
    result.add appState.getItem objId.getStr

    
proc buildHeader(def: JsonNode): VNode =
  var h = copy components["header"]
  # WARNING: hardcoded
  h["children"][0]["children"][0]["children"][0]["children"][0]["children"][0]["text"] = def["alternative"]
  result = buildComponent h

proc buildBody(action: string, bodyDefinition: var JsonNode): VNode =
  # builds the initial ui based on the definition and the components library
  # this part should understand and comply with the component definition specification
  var def = bodyDefinition
  result = newVNode VnodeKind.tdiv
  result.class = "container"
  case action
  of "show":
    # for some reason it fails with a second redraw, `copy` prevents it.
    let current = copy getCurrent(appState, def["model"].getStr)
    # get the list of entities related to the current selected entity
    if current.hasKey "relations":
      for relType, relIds in current["relations"].getFields:
        current{"relations", relType} = getModelList relIds
    result.add buildComponent sm.renderImpl(components, def, current)
  of "edit":
    let
      modelName = def["model"].getStr
    var
      current = getCurrent(appState, modelName)
      form = buildComponent em.renderImpl(components, def, current)
      h3 = newVNode VNodeKind.h3 # default heading file should come from configuration
      label = ""
      
    if def.hasKey "label": label = def["label"].getStr
    else: label = "Edit " & capitalize def["model"].getStr
    h3.add text label
    form.insert h3, 0
    # preventing default submision
    form.addEventListener EventKind.onsubmit, proc (ev: Event, n: Vnode) =
                                                ev.preventDefault
    result.add form
  of "list":
    let
      modelName = def["model"].getStr
      ids = appState.getList modelName
    if ids.len > 0:
      let modelList = getModelList ids
      result.add buildComponent lm.renderImpl(components, def, modelList)
  else:
    # look up in the components table and try to build it
    discard
    # var compDef = copy components[k]
    # let c = buildComponent compDef
    # result.add c

  
proc updateUIRaw*(state: JsonNode): VNode =
  # builds the vdom tree using the ui attribute
  result = buildComponent state["ui"]

  
proc updateUI*(state: var JsonNode): VNode =
  var
    uiDef = state["definition"]
    definition = uiDef

  var route, action: string
  if appState.hasKey("route") and appState["route"].getStr != "":
    let splitRoute = appState["route"].getStr.split "/"
    # just asume first item is `#`.
    # use `#` in the ui definition to know it is a route.
    route = splitRoute[0..1].join "/"
    if splitRoute.len > 2: action = splitRoute[2]

  result = newVNode VnodeKind.tdiv
  for section in Sections:
    var sectionDef = uiDef[$section]
    case $section
    of "body":
      var routeSec: JsonNode
      if action == "": routeSec = sectionDef[route]
      else: routeSec = sectionDef[route][action]
      result.add buildBody(action, routeSec)
    of "header":
      result.add buildHeader sectionDef
    of "menu":
      var uiType = sectionDef["ui-type"].getStr
      if not components.hasKey uiType:
        uiType = "menu"
      result.add buildComponent components[uiType]
    else:
      if components.hasKey $section:
        result.add buildComponent components[$section]

    
proc initApp*(state: var JsonNode,
              event: proc(name, id: string): proc(ev: Event, n: VNode)): VNode =    
  let definition = state["definition"]
  appState = state
  components = state["components"]
  defaultEvent = event
  result = updateUI state
