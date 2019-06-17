
import json, tables, sequtils, strutils, unicode
import ../ui_utils


proc sectionHeader(ctxt: AppContext, templates, obj: JsonNode): JsonNode =
  # get definition from schema
  let currentType = obj["type"].getStr
  
  var hc = copy templates["gridColumn"]
  hc["children"].add %*{
    "ui-type": %"h3",
    "children": %[ %*{"ui-type": "#text", "text": %(genLabel currentType)} ]}
  
  var hr = copy templates["gridRow"]
  hr["children"].add hc
  hr["children"].add newButton(templates["button"], obj["id"].getStr, currentType, "edit")
  hr["children"].add newButton(templates["button"], obj["id"].getStr, currentType, "done")
  
  result = copy templates["container"]
  result["children"].add hr
  
  for key, val in obj.getFields:
    if not ctxt.ignoreField key:
      # fileds
      var
        fr = copy templates["gridRow"]
        fkc = copy templates["gridColumn"]
        fvc = copy templates["gridColumn"]
      
      fkc["children"].add %*{
        "ui-type": %"h4",
        "children": %[%*{"ui-type": "#text", "text": %(genLabel capitalize key & ":")}]}
      
      fvc["children"].add %*{
        "ui-type": %"h5",
        "children": %[%*{"ui-type": "#text", "text": %(genLabel val.getStr)}]}
      
      fr["children"].add fkc
      fr["children"].add fvc
      result["children"].add fr


var DetailModel* = proc(ctxt: AppContext, def: JsonNode, data: JsonNode = nil): JsonNode =
  let
    templates = ctxt.state["templates"]
    tschema = ctxt.state["schema"][def["model"].getStr]

  if not data.isNil:
    result = sectionHeader(ctxt, templates, data)
  
