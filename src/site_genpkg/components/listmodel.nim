
import json, tables, sequtils, strutils, unicode
import ./uicomponent

# List based in the model object with a select button

proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true


proc render(appState, def: JsonNode, modelList: JsonNode = nil): JsonNode =
  # `modelList` is of kind jsonArray with the objects

  let templates = appState["templates"]
  result = %*{"ui-type": %"div", "children": %[]}

  let
    modelName = def["model"].getStr
    l = capitalize modelName.replace("_", " ")
  
  var h = %*{"ui-type": %"div",
              "children": %[
                %*{"ui-type": %"h4", "children":
                  %[ %*{"ui-type": %"text", "text": %(l)}]}
            ]}
            
  result["children"].add h
  
  var b = copy templates["button"]
  
  b["children"][0]["text"] = if def.hasKey "mode": def["mode"] else: %"New"  
  b["model"]  = def["model"]
  b["action"]  = if def.hasKey("mode") and def["mode"] == %"add": %"add"
                 else: %"edit"
  
  b["events"] = %["onclick"]
  result["children"].add b
  
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
          "children": %[%*{ "ui-type": "#text", "text": %(capitalize k)}]
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
        
      var detailB = copy templates["button"]
      detailB["children"][0]["text"] = %"Detail"
      detailB["events"] = %["onclick"]
      detailB["attributes"]= %*{"model": %modelName, "action": %("show")}
      detailB["id"] = elem["id"]
      detailB["objid"] = elem["id"]
      tr["children"].add detailB

      # if we are listing as add mode, the list is inside a show component
      let act = if def.hasKey("mode") and def["mode"] == %"add": "delete"
                else: "select"
      let txt = if def.hasKey("mode") and def["mode"] == %"add": "Remove"
                else: "Select"
      
      var selectB = copy templates["button"]
      selectB["children"][0]["text"] = %txt
      selectB["events"] = %["onclick"]
      selectB["attributes"]= %*{"model": %modelName, "action": %(act), "objid": elem["id"]}
      selectB["id"] = elem["id"]
      selectB["objid"] = elem["id"]
      tr["children"].add selectB 
      
      tbody["children"].add tr
    tab["children"].add tbody
    result["children"].add tab

  
type
  ListModel* = object of BaseComponent


proc newListModel*(): ListModel = 
  result = newBaseComponent(ListModel, render)
