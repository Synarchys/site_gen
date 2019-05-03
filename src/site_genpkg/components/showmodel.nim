
import json, tables, sequtils, strutils, unicode
import ./uicomponent
import ./listmodel

var lm = newListModel()

proc ignore(key: string): bool =
  #returns true if the row has to be ignored
  if key == "id" or key == "relations" or key == "type" or
     key.contains("_id") or key.contains("id_"):
    result = true
  result = false

proc sectionHeader(templates, obj: JsonNode): JsonNode =
  # get definition from schema
  let currentType = obj["type"].getStr
  
  # Displays the entity and its fields as header
  # ignore fileds `ìd`, `type`, `relations`, `id_*` and `_id*`
  var b = copy templates["button"]
  b["children"][0]["text"] = %"Edit"
  b["events"] = %["onclick"]
  b["id"] = obj["id"]
  b["attributes"]= %*{"model": %(obj["type"]), "name": %"edit"}
  
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


proc render(templates, def: JsonNode, data: JsonNode = nil): JsonNode =
  ## Generates a Header using the main object and
  ## generates lists with its relations
  if not data.isNil:
    result = sectionHeader(templates, data)
    if data.hasKey("relations"):
      for relType, modelList in data["relations"].getFields:
        var l = %*{"ui-type": %"div",
                    "children": %[
                      %*{"ui-type": %"h4", "children":
                        %[ %*{"ui-type": %"text", "text": %(capitalize relType)}]}
                  ]}
        let child = lm.renderImpl(templates, %*{"model": %relType}, modelList)
        if not child.isNil:
          l["children"].add child
        result["children"].add l


type
  ShowModel* = object of BaseComponent


proc newShowModel*(): ShowModel = 
  result = newBaseComponent(ShowModel, render)
