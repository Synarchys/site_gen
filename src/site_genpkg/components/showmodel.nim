
import json, tables, sequtils, strutils, unicode
import ./uicomponent
import ./listmodel

var lm = newListModel()

proc ignore(key: string): bool =
  # ignore fileds `ìd`, `type`, `relations`, `id_*` and `_id*`
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true

proc sectionHeader(templates, obj: JsonNode): JsonNode =
  # get definition from schema
  let currentType = obj["type"].getStr
  
  var b = copy templates["button"]
  b["children"][0]["text"] = %"Edit"
  b["events"] = %["onclick"]
  b["id"] = obj["id"]
  b["attributes"]= %*{"model": %(obj["type"]), "action": %"edit"}
  
  var hc = copy templates["gridColumn"]
  hc["children"].add %*{
    "ui-type": %"h3",
    "children": %[ %*{"ui-type": "#text", "text": %(capitalize currentType)} ]}
  
  var hr = copy templates["gridRow"]
  hr["children"].add hc
  hr["children"].add b
  
  result = copy templates["container"]
  result["children"].add hr
  
  for key, val in obj.getFields:
    if not ignore key:
      # fileds
      var
        fr = copy templates["gridRow"]
        fkc = copy templates["gridColumn"]
        fvc = copy templates["gridColumn"]
      
      fkc["children"].add %*{
        "ui-type": %"h4",
        "children": %[%*{"ui-type": "#text", "text": %(capitalize key & ":")}]}
      
      fvc["children"].add %*{
        "ui-type": %"h5",
        "children": %[%*{"ui-type": "#text", "text": %(val.getStr)}]}
      
      fr["children"].add fkc
      fr["children"].add fvc
      result["children"].add fr


proc render(appState, def: JsonNode, data: JsonNode = nil): JsonNode =
  ## Generates a Header using the main object and
  ## generates lists with its relations
  let
    templates = appState["templates"]
    tschema = appState["schema"][def["model"].getStr]
    
  if not data.isNil:
    result = sectionHeader(templates, data)
    var dataRelations: seq[string] = @[]
    
    if tschema.hasKey "relations":
      for relType, props in tschema["relations"].getFields:
        var l: JsonNode
        
        #if we have data use the list component
        if (data.hasKey "relations") and (data["relations"].hasKey relType):
          let modelList = data["relations"][relType]
          l = lm.renderImpl(appState, %*{"model": %relType, "mode": "add"}, modelList)
          
        else:
          l = lm.renderImpl(appState, %*{"model": %relType, "mode": "add"})
          
          # let relname = capitalize relType.replace("_", " ")
          # l = %*{"ui-type": %"div",
          #       "children": %[
          #         %*{"ui-type": %"h4", "children":
          #           %[ %*{"ui-type": %"text", "text": %(relname)}]}
          #       ]}
          # var b = copy templates["button"]
          # b["children"][0]["text"] = %"Add"
          # b["events"] = %["onclick"]
          # b["attributes"]= %*{"model": %(relType), "action": %"list"}
          # l["children"].add b
                  
        if not l.isNil:
          result["children"].add l


type
  ShowModel* = object of BaseComponent


proc newShowModel*(): ShowModel = 
  result = newBaseComponent(ShowModel, render)
