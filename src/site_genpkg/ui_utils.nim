
import json, jsffi, tables, strutils, unicode

import appcontext
export appcontext


proc ignoreField*(ctxt: AppContext, key: string): bool =
  # ignore fileds `ìd`, `type`, `relations`, `id_*` and `_id*`
  #returns true if the row has to be ignored
  if not ctxt.ignoreField.isNil:
    result = ctxt.ignoreField(key)
  else:
    if key == "id" or key == "relations" or key == "type" or
       key.contains("_id") or key.contains("id_"):
      result = true


proc genLabel(text: string): string =
  result = ""
  for i in text.split "_":
    result = result & " " &  (capitalize i)

      
proc labelFormat*(ctxt: AppContext, text: string): string =
  if not ctxt.labelFormat.isNil:
    result = ctxt.labelFormat text
  else:
    result = genLabel text
      

proc newButton*(b: JsonNode, id="", model, action: string, text="", mode= ""): JsonNode =
  result = copy b
  result["children"][0]["text"] = if text != "": %text else: %(genLabel action)
  result["events"] = %["onclick"]
  result["attributes"]= %*{"model": %model, "action": %action}
  if id != "":
    result["id"] = %id
    result["objid"] = %id
  if mode != "": result["objid"] = %mode
    

# ui helper procs
proc addChild*(parent: var JsonNode, child: JsonNode) =
  if not parent.haskey "children": parent["children"] = %[]
  parent["children"].add child


proc addText*(parent: var JsonNode, text: string) =
  var txt = %*{"ui-type": %"#text", "text": %text}
  parent.addChild(txt)


proc setText*(parent: var JsonNode, text: string) =
  if not parent.haskey("children") or parent["children"].isNil:
    parent["children"] = %[]
  
  for c in parent["children"].items:
    if c["ui-type"] == %"#text" or c["ui-type"] == %"text":
      c["text"] = %text
      break

  
proc setAttribute*(parent: var JsonNode, key, value: string) =
  ## if it does not exist it is added
  parent{"attributes", key} = %value


proc addEvent*(parent: var JsonNode, event: string) =
  ## if it does not exist it is added
  if not parent.haskey "events": parent["events"] = %[]
  if not parent["events"].contains %event:
    parent["events"].add %event

  
proc getElement*(uiComponent: JsonNode, key, value: string): JsonNode =
  # returns the first match
  if uiComponent.hasKey(key) and uiComponent[key] == %value:
    result = uiComponent
  elif uiComponent.hasKey("children"):
    for child in uiComponent["children"].getElems:      
      result = getElement(child, key, value)
      if result != nil:
        break

      
proc getValue*(uiComponent: JsonNode, key, attr: string): JsonNode =
  let elem = getElement(uiComponent, key, attr)
  if elem.hasKey("value"):
    result = elem["value"]
  elif uiComponent.hasKey("text"):
    result = elem["text"]

    
proc getElementById*(uiComponent: JsonNode, id: string): JsonNode =
  getElement(uiComponent, "id", id)


proc getValueById*(uiComponent: JsonNode, id: string): JsonNode =
  getValue(uiComponent, "id", id)


proc updateValue*(uiComponent: var JsonNode, id, value: string) =
  if uiComponent.hasKey("id") and uiComponent["id"] == %id:
    uiComponent["value"] = %value
  elif uiComponent.hasKey("children"):
    for child in uiComponent["children"].getElems:
      var c = child
      updateValue(c, id, value)

      
proc getAttribute*(uiComponent: var JsonNode, id, attr: string): JsonNode =
  var element = getElement(uiComponent, "id", id)
  if element.hasKey("attributes"):
    if element["attributes"].hasKey(attr):
      result = element["attributes"][attr]

      
proc setAttribute*(uiComponent: var JsonNode, id, attr, value: string) =
  # looks up in the components graph
  var element = getElement(uiComponent, "id", id)
  if not element.hasKey("attributes"):
    element["attributes"] = %*{}
  element["attributes"].add(attr, %value)
  

proc findElementsByAttrKey*(uiComponent: JsonNode, attrKey: string): seq[JsonNode] =
  # returns a sequence
  result = newSeq[JsonNode]()
  if uiComponent.hasKey("attributes"):
    if uiComponent["attributes"].hasKey(attrKey):
        result.add(uiComponent)
  if uiComponent.hasKey("children"):
    for child in uiComponent["children"].getElems:
      result.add(findElementsByAttrKey(child, attrKey))

  
proc findElementsByAttrValue*(uiComponent: JsonNode, attrKey, attrVal: string): seq[JsonNode] =
  # returns a sequence
  result = newSeq[JsonNode]()
  if uiComponent.hasKey("attributes"):
    if uiComponent["attributes"].hasKey(attrKey):
      if(uiComponent["attributes"][attrKey].getStr == attrVal):
        result.add(uiComponent)
  if uiComponent.hasKey("children"):
    for child in uiComponent["children"].getElems:
      result.add(findElementsByAttrValue(child, attrKey, attrVal))



when defined(js):
  import karax / [vdom, kdom, karax]

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
