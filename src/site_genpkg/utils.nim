
import json, jsffi, tables, strutils

proc getElement*(state: JsonNode, key, attr: string): JsonNode =
  if state.hasKey(key) and state[key] == %attr:
    result = state      
  elif state.hasKey("children"):
    for child in state["children"].getElems:
      result = getElement(child, key, attr)
      if result != nil:
        break

  
proc getValue*(state: JsonNode, key, attr: string): JsonNode =
  let elem = getElement(state, key, attr)
  if elem.hasKey("value"):
    result = elem["value"]
  elif state.hasKey("text"):
    result = elem["text"]

    
proc getElementById*(state: JsonNode, id: string): JsonNode =
  getElement(state, "id", id)


proc getValueById*(state: JsonNode, id: string): JsonNode =
  getValue(state, "id", id)


proc updateValue*(state: var JsonNode, id, value: string) =
  if state.hasKey("id") and state["id"] == %id:
    state["value"] = %value
  elif state.hasKey("children"):
    for child in state["children"].getElems:
      var c = child
      updateValue(c, id, value)

  
proc getAttribute*(state: var JsonNode, id, attr: string): JsonNode =
  var element = getElement(state, "id", id)
  if element.hasKey("attributes"):    
    if element["attributes"].hasKey(attr):
      result = element["attributes"][attr]


proc setAttribute*(state: var JsonNode, id, attr, value: string) =
  var element = getElement(state, "id", id)
  if not element.hasKey("attributes"):
    element["attributes"] = %*{}
  element["attributes"].add(attr, %value)
  
