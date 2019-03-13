import json, tables, sequtils, strutils
import ./uicomponent


proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true


proc formGroup(components, def: JsonNode): JsonNode =
  result = copy components["formGroup"]  
  var component: JsonNode
  let uiType = $def["ui-type"].getStr  
  if components.haskey uiType:
    component = copy components[uiType]
  else:    
    if uiType == "check":
      component = copy components["checkbox"]
    elif uiType == "text":
      component = copy components["textarea"]
    elif uiType == "input":
      component = copy components["input"]
    else:
      # TODO: raise error
      echo "Error: ui-type ", uiType, "not found."

  if def.hasKey "events":
    # add events to component we are preparing
    component["events"] = copy def["events"]    
  if def.hasKey "name":
    component["name"] = copy def["name"]
  if def.hasKey "model":
    component["model"] = copy def["model"]
  if def.hasKey "value":
    component["value"] = copy def["value"]

  result["children"][0]["text"] = %(def["label"].getStr & ":")
  result["children"][0]{"attributes","for"} = component["name"]
  result["children"].add component

    
proc render(components, formDef: JsonNode, data:JsonNode = nil): JsonNode =
  let modelName = formDef["model"].getStr
  
  var form = %*{
    "ui-type": "form",
    "name": formDef["name"],
    "model": formDef["model"]
  }
  let current = data #getCurrent(appState, modelName)
  form["children"] = newJArray()
  for item in formDef["children"].getElems:
    let fieldName = item["name"].getStr
    if not ignore fieldName:
      var child: JsonNode
      item["model"] = %modelName
      if item["ui-type"].getStr == "button":
        child = copy components["button"]
        child["model"] = %modelName
        child["name"] = if item.hasKey fieldName: copy item[fieldName] else: %fieldName
        child["events"] = copy item["events"]
        child["children"][0]["text"] = item["label"]
        if not current.isNil: child["id"] = current["id"]
      else:
        # if item is input use formGroup
        if not current.isNil: item["value"] = current[fieldName]
        child = formGroup(components, item)
      form["children"].add child
  form


type
  EditForm* = object of BaseComponent

proc newEditForm*(): EditForm = 
  result = newBaseComponent(EditForm, render)
