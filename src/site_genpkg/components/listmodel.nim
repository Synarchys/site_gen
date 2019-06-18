
import json, tables, sequtils, strutils, unicode
import ../ui_utils

# List based in the model object with a select button

# proc ignore(key: string): bool =
#   #returns true if the row has to be ignored
#   if key == "id" or key == "relations" or key == "type" or
#      key.contains("_id") or key.contains("id_"):
#     result = true


proc ListModel*(ctxt: AppContext, def: JsonNode, modelList: JsonNode = nil): JsonNode =
  # `modelList` is of kind jsonArray with the objects

  let templates = ctxt.state["templates"]
  result = %*{"ui-type": %"div", "children": %[]}
  
  let
    modelName = def["model"].getStr
    l = ctxt.labelFormat modelName
  
  var h = %*{"ui-type": %"div",
              "children": %[
                %*{"ui-type": %"h4", "children":
                  %[ %*{"ui-type": %"text", "text": %(l)}]}
            ]}
            
  result["children"].add h
  
  # `select` action redirects to a list to select one
  # `new` redirects to edit mode with a new object set as current
  if def.hasKey "mode":
    let
      txt = if def["mode"] == %"add": "Add" else: "New"
      act = if def["mode"] == %"add": "add" else: "new"

    var parentId = if def.haskey "objid": def["objid"].getStr else: ""
    
    result["children"].add newButton(templates["button"], parentId, def["model"].getStr, act, txt)
  
  if not modelList.isNil and modelList.len > 0:
    var
      tab = copy templates["table"]
      row = %*{ "ui-type": %"tr", "children": %[] }
      trh = copy row
    
    for k, v in modelList[0].getFields:
      # create header
      if not ctxt.ignoreField k:
        var th = %*{
          "ui-type": %"th",
          "attributes": %*{"scope": %"col"},
          "children": %[%*{ "ui-type": "#text", "text": %(ctxt.labelFormat k)}]
        }
        trh["children"].add th
    tab["children"].add %{"ui-type": %"thead", "children": %[trh]}
    
    var tbody = %*{"ui-type": %"tbody", "children": %[]}
    for elem in modelList.getElems:
      var tr = copy row
      for k, v in elem.getFields:
        if not ctxt.ignoreField k:
          # each row will contain: fields and values, and detail button
          # iterte over fields  
          var cellVal = v.getStr
          var cell = %*{
            "ui-type": %"td",
            "children": %[%*{"ui-type": "#text", "text": %cellVal}]
          }
          tr["children"].add cell
      
      let b = newButton(templates["button"], elem["id"].getStr, modelName, "show")
      tr["children"].add b
      
      # if we are listing as `add` mode, the list is inside a show component
      # if we are listing as `select` mode, we came from a show/add view.
      if def.hasKey("mode") and def["mode"] != %"list":
        let
          act = if def["mode"] == %"add": "delete" else: "select"
          txt = if def["mode"] == %"add": "Remove" else: "Select"
      
        tr["children"].add newButton(templates["button"], elem["id"].getStr, modelName, act, txt)
      
      tbody["children"].add tr
    tab["children"].add tbody
    result["children"].add tab
