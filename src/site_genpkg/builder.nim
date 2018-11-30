
include karax / prelude 
import karax / [vdom, prelude, vstyles]

import json, jsffi, tables
import uuidjs


proc buildComponent*(params: JsonNode): VNode =
  ## builds a component based on a json definition
  # TODO: add the id to the component here
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

  if params.hasKey("id"):
    result.id = params["id"].getStr
    
  if params.hasKey("class"):
    result.class = params["class"].getStr

  if params.hasKey("attributes"):
    for k, v in params["attributes"].fields:
      result.setAttr(k, v.getStr)

  if params.hasKey("children"):
    for child in params["children"].getElems:
      result.add(buildComponent(child))


proc toJson*(component: VNode): JsonNode =
  ## returns a JsonNode from a VNode
  result = %*{
    "id": genUUID(),
    "ui-type": $component.kind
  }

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

