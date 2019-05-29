 
import json, tables, sequtils, strutils, unicode, times
import ./uicomponent, ../ui_utils


proc RadioItem(text, value: string): JsonNode =
  var result = %*{"ui-type": "input"}
  result.setAttribute("class", "form-check-input")
  result.setAttribute("type", "checkbox")
  result.setAttribute("value", value)  
  var label = %*{"ui-type": "lable"}
  label.setAttribute("class", "form-check-label")
  label.addText text
  result.addChild label  

  
proc Radio(data: JsonNode): JsonNode =
  # data is a jarray of objects {key: val}  
  result = %*{"ui-type": "div"}
  result.setAttribute("class", "form-check")  
  for key, value in data.pairs:
    var ch = RadioItem(key, value.getStr)
    result.addChild ch

  
proc formGroup(templates, uidef: JsonNode): JsonNode =
  result = copy templates["formGroup"]
  
  var
    def = uidef
    component: JsonNode
  
  let uiType = $def["ui-type"].getStr
  
  if templates.haskey uiType:
    component = copy templates[uiType]
  else:
    if uiType == "check" or uiType == "checkbox":
      component = copy templates["checkbox"]
      if def.haskey("type") and def["type"] == %"boolean":
        if def.hasKey("value") and def["value"] == %"true":          
          component{"attributes","checked"} = %"true"
        elif component.haskey("attributes") and component["attributes"].haskey("checked"):
          delete(component["attributes"], "checked")

    elif uiType == "boolean": # default bolean ui
      if def.haskey("type") and def["type"] == %"boolean":
        if def.hasKey("value") and def["value"] == %"true":
          component = Radio( %*{"Yes": "true", "No": "false"})
        else:
          component = Radio( %*{"Yes": "false", "No": "true"})

    elif uiType == "text":
      component = copy templates["textarea"]
    elif uiType == "input":
      component = copy templates["input"]
    elif uiType == "datetime":
      component = copy templates["input"]
      component{"attributes","type"} = %"datetime"

    else:
      # TODO: raise error
      echo "Error: ui-type ", uiType, " not found."

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


proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true

    
var EditModel* =proc(appState, formDef: JsonNode, data: JsonNode = nil): JsonNode =
  let
    templates = appState["templates"]
    modelName = formDef["model"].getStr
    
  var form = %*{
    "ui-type": "form",
    "name": formDef["name"],
    "model": formDef["model"]
  }
  
  let current = data
  form["children"] = newJArray()
  form["children"].add %*{"ui-type": %"h3",
                           "children": [{
                             "ui-type": %"text",
                             "text": %genLabel(modelName)}
                           ]
                         }
  
  for item in formDef["children"].getElems:
    var fieldName: string
    if item.haskey "action":
      fieldName = item["action"].getStr
    elif item.haskey "name":
      fieldName = item["name"].getStr
    
    if not ignore fieldName:
      var child: JsonNode
      item["model"] = %modelName
      if item["ui-type"].getStr == "button":
        # deprecated
        child = copy templates["button"]
        child["model"] = %modelName
        child["action"] = if item.hasKey fieldName: copy item[fieldName] else: %fieldName
        child["events"] = copy item["events"]
        child["children"][0]["text"] = item["label"]
        if not current.isNil: child["id"] = current["id"]
        
      else:
        if not current.isNil and current.hasKey(fieldName):
          item["value"] = current[fieldName]
        child = formGroup(templates, item)
      form["children"].add child
  let id = if data.haskey "id": data["id"].getStr else: ""
  
  form["children"].add newButton(templates["button"], id, data["type"].getStr, "save")
  form["children"].add newButton(templates["button"], id, data["type"].getStr, "cancel")
  
  form
