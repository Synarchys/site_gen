
import json, tables, sequtils, strutils, unicode
import ../ui_utils, ./detailmodel, ./listmodel


proc ShowModel*(ctxt: AppContext, def: JsonNode, data: JsonNode = nil): JsonNode =
  ## Generates a Header using the main object and
  ## generates lists with its relations
  let
    templates = ctxt.state["templates"]
    tschema = ctxt.state["schema"][def["model"].getStr]

  if not data.isNil and data.kind != JNull:
    result = DetailModel(ctxt, def, data)
    
    if tschema.hasKey "relations":
      for relType, props in tschema["relations"].pairs:
        var l: JsonNode
        if data.hasKey("relations") and data["relations"].kind == JObject and
           data["relations"].hasKey(relType):
          let modelList = data["relations"][relType]
          
          l = ListModel(ctxt, %*{"model": %relType, "mode": "add"}, modelList)

        else:
          l = ListModel(ctxt, %*{"model": %relType, "mode": "add"})
        
        if not l.isNil and l.kind != JNull:
          result["children"].add l
