
import strutils, unicode

import json, tables, jsffi, sequtils
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import store, uuidjs
import components/ [editform, datepicker]


var defaultEvent: proc(name, id: string): proc(ev: Event, n: VNode)

# global variable that holds all components
var appState, components: JsonNode

type
  Sections = enum
    header, menu, body, footer


# ui components
var
  dp = newDatePicker()
  ef = newEditForm()

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


proc list(modelName: string, ids: JsonNode): JsonNode =
  # ids is a jsonNode of kind jsArray
  if ids.len > 0:
    var modelList = %[]
    for objId in ids:
      modelList.add appState.getItem objId.getStr
              
    result = %*{
      "ui-type": "table",
      "attributes": %*{"class": %"table"},
      "children": %[]
    }
    
    var row = %*{ "ui-type": %"tr", "children": %[] }
    # TODO: extract field names and use it as column headers
    # Header
    var tr = copy row    
    for k, v in modelList[0].getFields:
      # create header
      if not ignore k:
        var th = %*{
          "ui-type": %"th",
          "attributes": %*{"scope": %"col"},
          "children": %[%*{ "ui-type": "#text", "text": %(capitalize k)}]
        }
        tr["children"].add th
        result["children"].add %{"ui-type": %"thead", "children": %[tr]}

    var tbody = %*{"ui-type": %"tbody", "children": %[]}
    
    for elem in modelList.getElems:
      # each item in one row
      var tr = copy row
      for k, v in elem.getFields:
        if not ignore k:
          # each row will contain: fields and values, and detail button
          # iterte over fields  
          var cellVal = v.getStr
          var cell = %*{
            "ui-type": %"td",
            "children": %[%*{"ui-type": "#text", "text": %cellVal}]
          }
          if k == "id":
            cell["ui-type"] = %"th"
            cell["attributes"] = %*{"scope":"row"}
          tr["children"].add cell

      var b = copy components["button"]
      b["children"][0]["text"] = %"Detail"
      b["events"] = %["onclick"]
      b["id"] = elem["id"]
      b["attributes"]= %*{"model": %modelName, "name": %("show")}
      tr["children"].add(b)
      tbody["children"].add tr      
    result["children"].add tbody

  
proc buildHeader(def: JsonNode): VNode =
  var h = copy components["header"]
  # WARNING: hardcoded
  h["children"][0]["children"][0]["children"][0]["children"][0]["children"][0]["text"] = def["alternative"]
  result = buildComponent h


proc sectionHeader(obj: JsonNode): JsonNode =
  # get definition from schema
  let currentType = obj["type"].getStr
  
  # Displays the entity and its fields as header
  # ignore fileds `ìd`, `type`, `relations`, `id_*` and `_id*`
  var b = copy components["button"]
  b["children"][0]["text"] = %"Edit"
  b["events"] = %["onclick"]
  b["id"] = obj["id"]
  b["attributes"]= %*{"model": %(obj["type"]), "name": %"edit"}
  
  var hc = copy components["gridColumn"]
  hc["children"].add %*{
    "ui-type": %"h3",
    "children": %[ %*{"ui-type": "#text", "text": %(capitalize currentType)}]}
  
  var hr = copy components["gridRow"]
  hr["children"].add hc
  hr["children"].add b
  #hr["children"].add DatePicker(components, %*{"model": %(obj["type"])})
  
  result = copy components["container"]
  result["children"].add hr
  
  for key, val in obj.getFields:
    if not ignore key:
      # fileds
      var
        fr = copy components["gridRow"]
        fkc = copy components["gridColumn"]
        fvc = copy components["gridColumn"]
      
      fkc["children"].add %*{
        "ui-type": %"h4",
        "children": %[%*{"ui-type": "#text", "text": %(capitalize key & ":")}]}
      
      fvc["children"].add %*{
        "ui-type": %"h5",
        "children": %[%*{"ui-type": "#text", "text": %(val.getStr)}]}
      
      fr["children"].add fkc
      fr["children"].add fvc
      result["children"].add fr


proc show(def: JsonNode): VNode =
  ## Generates a Header using the main object and
  ## generates lists with its relations
  let current = getCurrent(appState, def["model"].getStr)
  result = buildComponent sectionHeader current
  if current.hasKey("relations"):
    for relType, relationIds in current["relations"].getFields:
      let l = buildHtml():
        tdiv():
          h4: text capitalize relType
          buildComponent(list(relType, relationIds))
      result.add l


proc buildBody(action: string, bodyDefinition: var JsonNode): VNode =
  # builds the initial ui based on the definition and the components library
  # this part should understand and comply with the component definition specification  
  var def = bodyDefinition
  result = newVNode VnodeKind.tdiv
  result.class = "container"
  case action
  of "show":
    result.add show def
  of "edit":
    let
      modelName = def["model"].getStr
    var
      current = getCurrent(appState, modelName)
      form = buildComponent ef.renderImpl(components, def, current)
      h3 = newVNode VNodeKind.h3 # default heading file should come from configuration
      label = ""
      
    if def.hasKey "label": label = def["label"].getStr
    else: label = "Edit " & capitalize def["model"].getStr
    
    h3.add text label
    form.insert h3, 0
    # preventing default submision
    form.addEventListener EventKind.onsubmit,
                              proc (ev: Event, n: Vnode) =
                                ev.preventDefault
    result.add form
  of "list":
    let
      modelName = def["model"].getStr
      ids = appState.getList modelName
    result.add buildComponent list(modelName, ids)
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
