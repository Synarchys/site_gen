
import json, tables, sequtils, strutils, unicode
import ./uicomponent

# List based in the model object with a select button

proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true


proc render(templates, def: JsonNode, modelList: JsonNode = nil): JsonNode =
  # `modelList` is of kind jsonArray with the objects
  if modelList.isNil:
    result = %*{"ui-type": %"div", "children": %[]}
    var b = copy templates["button"]
    b["children"][0]["text"] = %"New"
    b["model"]  = def["model"]
    b["name"]   = %"edit"
    b["events"] = %["onclick"]
    result["children"].add b
  else:
    result = copy templates["table"]
    let modelName = def["model"].getStr    
    var
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
    result["children"].add %{"ui-type": %"thead", "children": %[trh]}
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
      var b = copy templates["button"]
      b["children"][0]["text"] = %"Detail"
      b["events"] = %["onclick"]
      b["attributes"]= %*{"model": %modelName, "name": %("show")}
      b["id"] = elem["id"]
      tr["children"].add(b)
      tbody["children"].add tr      
    result["children"].add tbody

  
type
  ListModel* = object of BaseComponent


proc newListModel*(): ListModel = 
  result = newBaseComponent(ListModel, render)
