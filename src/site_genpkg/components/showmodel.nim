
import json, tables, sequtils, strutils, unicode
import ./uicomponent
import ./detailmodel, ./listmodel

var
  dm = newDetailModel()
  lm = newListModel()

proc render(appState, def: JsonNode, data: JsonNode = nil): JsonNode =
  ## Generates a Header using the main object and
  ## generates lists with its relations
  let
    templates = appState["templates"]
    tschema = appState["schema"][def["model"].getStr]

  if not data.isNil:    
    result = dm.renderImpl(appState, def, data)
    
    var dataRelations: seq[string] = @[]
    
    if tschema.hasKey "relations":
      for relType, props in tschema["relations"].getFields:
        var l: JsonNode
        if data.hasKey("relations") and data["relations"].hasKey(relType):
          let modelList = data["relations"][relType]
          l = lm.renderImpl(appState, %*{"model": %relType, "mode": "add"}, modelList)
        else:
          l = lm.renderImpl(appState, %*{"model": %relType, "mode": "add"})
                            
        if not l.isNil:
          result["children"].add l


type
  ShowModel* = object of BaseComponent


proc newShowModel*(): ShowModel = 
  result = newBaseComponent(ShowModel, render)
