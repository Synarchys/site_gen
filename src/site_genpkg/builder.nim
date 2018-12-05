
import strutils

include karax / prelude 
import karax / [vdom, prelude, vstyles]

import json, jsffi, tables, sequtils
import uuidjs

import wclient

# global variable that holds all components
var appState, components: JsonNode

proc extractData(vn: VNode, def: JsonNode) =
  # somehow no vnode is changed, no need to return
  var n = vn
  if n.kind == VnodeKind.input:
    # TODO: handle types (?)
    n.value = def["value"].getStr


proc buildComponent*(params: JsonNode): VNode =
  ## builds a component based on a json definition
  # TODO: remove definition specific code 
  # TODO: if the nodeKind is not found, lookup the components
  # table and call this with its contents
  
  var nodeKind: VNodeKind  
  for vnk in VNodeKind:
    if $vnk == params["ui-type"].getStr:
      nodeKind = vnk
      break

  if nodeKind == VNodeKind.text:
    # text kind has its own constructor
    result = text(params["text"].getStr)
  else:
    result = newVNode(nodeKind)

  result.id = if params.hasKey("id"): params["id"].getStr
              else: genUUID()

  if params.hasKey("text"):
    # if the component has a text parameter create a #text element
    result.add text(params["text"].getStr)
    
  if params.hasKey("class"):
    result.class = params["class"].getStr

  if params.hasKey("attributes"):
    for k, v in params["attributes"].fields:
      result.setAttr(k, v.getStr)

  if params.hasKey("children"):
    for child in params["children"].getElems:
      result.add(buildComponent(child))
      
  if params.hasKey("events"):
    # TODO: improve
    # if the component does not have a name quit with a message
    let
      events = params["events"]
      model = params["model"].getStr
      name = params["name"].getStr

    for evk in EventKind:
      if events.contains(%($evk)):
        let actionName = "$1_$2_$3" % [model, name, $evk]
        result.addEventListener(evk, defaultEvent(appState, actionName))
  
  if params.hasKey("value"):
    # it has de data of the component,
    # each component data is handed differently
    extractData(result, params)
    

proc toJson*(component: VNode): JsonNode =
  ## returns a JsonNode from a VNode
  # TODO: extract events and value(s)
  
  result = %*{ "ui-type": $component.kind }

  result["id"] = if component.id != nil: %($component.id) else: %genUUID()
  if component.class != nil: result["class"] = %($component.class)
  if component.text != nil: result["text"] = %($component.text)
  
  var attributes = %*{}
  for k,v in component.attrs:
    attributes.add($k,%($v))
  if attributes.len > 0: result["attributes"] = attributes
                           
  var children = newJArray()
  for c in component.items:
    children.add(toJson(c))
  if children.len > 0: result["children"] = children


proc formGroup(def: JsonNode): JsonNode =
  result = copy components["formGroup"]
  
  var component = if def["ui-type"].getStr == "check":
                    copy components["checkbox"]
                  elif $def["ui-type"].getStr == "text":
                    copy components["textarea"]
                  elif $def["ui-type"].getStr == "input":
                    copy components["input"]
                  # use input as default
                  else: copy components["input"]

  component["id"] = %genUUID()

  # for k, v in def.getFields:
  #   if k != "uit-ype": component[k] = v
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
  var form = %*{"ui-type": "form"}
  form["children"] = newJArray()
  
  for k1, v1 in formDef.getFields:
    if k1 == "children":
      for item in v1.getElems:
        # ?
        item["model"] = formDef["model"]
        let fg = formGroup(item)
        # check the ui-type to decide what to use
        form["children"].add(fg)
  form
  
proc buildBody(def: JsonNode, ): VNode =
  result = newVNode(VnodeKind.tdiv)
  result.class = "container"
  if def.hasKey("children"):
    let children = def["children"]
    for elem in children.getElems:
      for k, v in elem.getFields:
        if k == "edit":
          result.add(buildComponent(form(v)))
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
          

proc buildApp*(state: JsonNode): VNode =
  let definition = state["definition"]
  appState = state
  components = state["components"]
   
  result = buildHtml(tdiv):
    for k, v in definition.getFields:
      # FIXME: change this in the near future.
      if k == "body":
        let body = buildBody(v)
        body
      else:
        if components.hasKey(k):
          buildComponent(components[k])
