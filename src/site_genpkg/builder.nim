
import strutils

import json, tables, jsffi, sequtils
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import uuidjs
#import ui_utils

var defaultEvent: proc(name, id: string): proc(ev: Event, n: VNode)

# global variable that holds all components
var appState, components: JsonNode


proc toJson*(component: VNode): JsonNode =
  ## returns a JsonNode from a VNode
  result = %*{ "ui-type": $component.kind }

  result["id"] = if component.id != nil: %($component.id) else: %genUUID()
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


# proc setValue(vn: VNode, value:string): VNode =
#   # somehow no vnode is changed, no need to return
#   result = vn
#   if result.kind == VnodeKind.input:
#     result.value = value
#     echo $result


proc buildComponent*(params: JsonNode): VNode =
  ## builds a component based on a json definition
  var nodeKind: VNodeKind  
  for vnk in VNodeKind:
    if params.hasKey("ui-type"):
      if $vnk == params["ui-type"].getStr:
        nodeKind = vnk
        break
    else:
      echo params.pretty
      
  if nodeKind == VNodeKind.text:
    # text kind has its own constructor
    result = text(params["text"].getStr)
  else:
    result = newVNode(nodeKind)

  result.id = if params.hasKey("id"): params["id"].getStr
              else: genUUID()

  if params.hasKey("value"):
    # it has de data of the component,
    # each component data is handed differently
    # hack to update values
    result.id = $genUUID()
    setInputText(result, params["value"].getStr)

  # if nodeKind == VNodeKind.text and params.hasKey("text"):
  #   result.text = params["text"].getStr  #setValue(result, params["text"].getStr)
    
  if nodeKind == VNodeKind.label and params.hasKey("text"):
    result.add text(params["text"].getStr)
    
  if params.hasKey("class"):
    result.class = params["class"].getStr

  if params.hasKey("attributes"):
    for k, v in params["attributes"].fields:
      result.setAttr(k, v.getStr)

  if params.hasKey("children"):
    for child in params["children"].getElems:
      result.add(buildComponent(child))

  if params.hasKey("model"):
    result.setAttr("model", params["model"].getStr)

  if params.hasKey("name"):
    result.setAttr("name", params["name"].getStr)

  if params.hasKey("dataListeners"):
    result.setAttr("dataListeners", params["dataListeners"].getStr)
  
  if params.hasKey("events"):
    # TODO: improve
    # if the component does not have a name quit with a message
    let events = params["events"]
      
    for evk in EventKind:
      if events.contains(%($evk)):
        # FIXME: the way events are named and referenced is too simple
        # it will colide if the same model is used in another part of
        # the ui graph
        let actionName = "$1_$2_$3" % [$result.getAttr("model"), $result.getAttr("name"), $evk]
        result.addEventListener(evk, defaultEvent(actionName, $result.id))
      #else:
      #  echo "WARNING: event ", $evk, " does not exists." 

  
proc formGroup(def: JsonNode): JsonNode =
  result = copy components["formGroup"]
  
  var component: JsonNode

  let uiType = $def["ui-type"].getStr
  
  if components.haskey(uiType):
    component = copy components[uiType]
  else:    
    if uiType == "check":
      component = copy components["checkbox"]
    elif uiType == "text":
      component = copy components["textarea"]
    elif uiType == "input":
      component = copy components["input"]
    else:
      # raise error
      echo "Error: ui-type ", uiType, "not found."

  component["id"] = %genUUID()

  if def.hasKey("events"):
    # add events to component we are preparing
    component["events"] = copy def["events"]
  if def.hasKey("value"):
    component["value"] = copy def["value"]
  if def.hasKey("name"):
    component["name"] = copy def["name"]
  if def.hasKey("model"):
    component["model"] = copy def["model"]
    
  result["children"][0]["text"] = copy def["label"]
  result["children"][0]{"attributes","for"} = component["id"]
  result["children"].add(component)

  
proc form(formDef: JsonNode): JsonNode =
  var form = %*{"ui-type": "form",
                 "name": formDef["name"],
                 "model": formDef["model"]
               }
  form["children"] = newJArray()
  
  for k1, v1 in formDef.getFields:
    if k1 == "children":
      for item in v1.getElems:
        var child: JsonNode
        item["model"] = formDef["model"]
        # echo "ui - type  ", item["ui-type"]
        if item["ui-type"].getStr == "button":
          # just build it
          child = copy components["button"]
          # add the label or text as child so it can be displayed on the button
          child["model"] = formDef["model"]
          child["name"] = copy item["name"]
          child["events"] = copy item["events"]
          child["children"][0]["text"] = item["label"]
        else:
          # if item is input use formGroup
          child = formGroup(item)
        form["children"].add(child)
  form


proc buildHeader(def: JsonNode): VNode =
  var h = copy components["header"]
  h["children"][0]["children"][0]["children"][0]["children"][0]["children"][0]["text"] = def["alternative"]
  result = buildComponent(h)

  
proc buildBody(def: JsonNode, ): VNode =
  # builds the initial ui based on the definition and the components library
  # this part should understand and comply with the component definition specification
  result = newVNode(VnodeKind.tdiv)
  result.class = "container"
  if def.hasKey("children"):
    let children = def["children"]
    for elem in children.getElems:
      for k, v in elem.getFields:
        if k == "edit":
          var vNodeForm = buildComponent(form(v))
          # preventing default submision
          vNodeForm.addEventListener(EventKind.onsubmit,
                                     proc(ev: Event, n: Vnode) =
                                       ev.preventDefault())
          result.add(vNodeForm)
        elif k == "list":
          # TODO
          var ul = newVNode(VnodeKind.ul)
          result.add(ul)
          echo "TODO: create a list with its childs or use the model if nothing is defined"
        elif k == "gird":
          #TODO:
          echo "TODO: create a grid"
        else:
          # look up in the components table and try to build it
          var compDef = copy components[k]
          let c = buildComponent(compDef)
          result.add(c)
          

proc updateUI*(ui: JsonNode): VNode =
  # builds the vdom tree using the ui attribute
  result = buildComponent(ui)

    
proc initApp*(state: JsonNode, event: proc(name, id: string): proc(ev: Event, n: VNode)): VNode =
    
  let definition = state["definition"]
  appState = state
  components = state["components"]
  defaultEvent = event
  
  result = buildHtml(tdiv):
    for k, v in definition.getFields:
      if k == "body":
        buildBody(v)
      elif k == "header":
        buildHeader(v)
      elif k == "menu":
        # basic ui replacement logic 
        var uiType = v["ui-type"].getStr
        if not components.hasKey(uiType):
          uiType = k
        echo components[uiType].pretty
        buildComponent(components[uiType])
      else:
        if components.hasKey(k):
          buildComponent(components[k])
    
