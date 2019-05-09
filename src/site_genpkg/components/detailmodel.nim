

import json, tables, sequtils, strutils, unicode
import ./uicomponent

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
  let
    templates = appState["templates"]
    tschema = appState["schema"][def["model"].getStr]

  if not data.isNil:
    result = sectionHeader(templates, data)
  

type
  DetailModel* = object of BaseComponent


proc newDetailModel*(): DetailModel = 
  result = newBaseComponent(DetailModel, render)
