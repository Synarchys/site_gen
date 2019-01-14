
import json, jsffi, tables, strutils

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
