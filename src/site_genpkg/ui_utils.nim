
import json, jsffi, tables, strutils, unicode


type
  AppContext* = object of RootObj
    state*: JsonNode
    components*: Table[string, proc(ctxt: AppContext, uidef, payload: JsonNode): JsonNode]
    actions*: Table[cstring, proc(payload: JsonNode)]
    ignoreField*: proc(field: string): bool # proc that returns true if the field should be ignored
    renderer*: proc (payload: JsonNode)
    labelFormater*: proc(text: string): string


proc ignoreField*(ctxt: AppContext, key: string): bool =
  # ignore fileds `ìd`, `type`, `relations`, `id_*` and `_id*`
  #returns true if the row has to be ignored
  if not ctxt.ignoreField.isNil:
    result = ctxt.ignoreField(key)
  else:
    if key == "id" or key == "relations" or key == "type" or
       key.contains("_id") or key.contains("id_"):
      result = true

proc newButton*(b: JsonNode, id="", model, action: string, text="", mode= ""): JsonNode =
  result = copy b
  result["children"][0]["text"] = if text != "": %text else: %(capitalize action)
  result["events"] = %["onclick"]
  result["attributes"]= %*{"model": %model, "action": %action}
  if id != "":
    result["id"] = %id
    result["objid"] = %id
  if mode != "": result["objid"] = %mode
    
                          
proc genLabel*(text: string): string =
  result = ""
  for i in text.split "_":
    result = result & " " &  (capitalize i)


# ui helper procs
proc addChild*(parent: var JsonNode, child: JsonNode) =
  if not parent.haskey "children": parent["children"] = %[]
  parent["children"].add child


proc addText*(parent: var JsonNode, text: string) =
  var txt = %*{"ui-type": %"text", "text": %text}
  parent.addChild(txt)


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
