
import json, tables, sequtils, strutils, unicode
import ./uicomponent, ../ui_utils

# List based in the model object with a select button

proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true


proc ListModel*(appState, def: JsonNode, modelList: JsonNode = nil): JsonNode =
  # `modelList` is of kind jsonArray with the objects

  let templates = appState["templates"]
  result = %*{"ui-type": %"div", "children": %[]}
  
  let
    modelName = def["model"].getStr
    l = genLabel modelName
  
  var h = %*{"ui-type": %"div",
              "children": %[
                %*{"ui-type": %"h4", "children":
                  %[ %*{"ui-type": %"text", "text": %(l)}]}
            ]}
            
  result["children"].add h

  # `add` action redirects to a list to select one
  # `new` redirects to edit mode with a new object set as current
  
  let
    txt = if def.hasKey "mode": capitalize(def["mode"].getStr) else: "New"  
    ac = if def.hasKey("mode") and def["mode"].getStr == "add": "add"
                  else: "new"
  
  result["children"].add newButton(templates["button"], "", def["model"].getStr, ac, txt)
  
  if not modelList.isNil and modelList.len > 0:
    var
      tab = copy templates["table"]
      row = %*{ "ui-type": %"tr", "children": %[] }
      trh = copy row
    
    for k, v in modelList[0].getFields:
      # create header
      if not ignore k:
        var th = %*{
          "ui-type": %"th",
          "attributes": %*{"scope": %"col"},
          "children": %[%*{ "ui-type": "#text", "text": %(genLabel k)}]
        }
        trh["children"].add th
    tab["children"].add %{"ui-type": %"thead", "children": %[trh]}
    
    var tbody = %*{"ui-type": %"tbody", "children": %[]}
    for elem in modelList.getElems:
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
          tr["children"].add cell

      tr["children"].add newButton(templates["button"], elem["id"].getStr, modelName, "show")
      # if we are listing as add mode, the list is inside a show component
      
      let act = if def.hasKey("mode") and def["mode"] == %"add": "delete"
                else: "select"
      let txt = if def.hasKey("mode") and def["mode"] == %"add": "Remove"
                else: "Select"
      
      tr["children"].add newButton(templates["button"], elem["id"].getStr, modelName, act, txt)
      
      tbody["children"].add tr
    tab["children"].add tbody
    result["children"].add tab
