
## This module generates parts or the whole ui-definition based on the
## the model (the data schema).

import json, tables, unicode


proc editModel(appState, def: JsonNode) =
  let
    modelName = def["model"].getStr
    model = appState["schema"][modelName]
    
  var newV = def
  newV.add("children", %[])
  for field, fieldType in model.getFields:
    if field != "id" and fieldType.getStr == "string":
      newV["children"].add(
        %*{
          "name": %field,
          "label": %(capitalize field), # uppercase first character
          "type": fieldType,
          "ui-type": %"input"
      })

  # default submit button
  var b =  %*{
      "name": %"save_button",
      "ui-type": %"button",
      "label": %"Save",
      "events": %["onclick"]
  }
  if model.haskey "id": b["id"] = model["id"]
  newV["children"].add b
     
proc listModel(appState, def: JsonNode) =
  # use data to create the list
  let
    modelName = def["model"].getStr
    model = appState["schema"][modelName]


proc showModel(appState, def: JsonNode) =
  discard


const ACTIONS = ["list", "show", "edit"]

proc generateBody*(schema: JsonNode): JsonNode =
  result = %*{}
  for tabName, value in schema:
    let route = "#/" & tabName
    result[route] = %*{"model": %tabName}
    for a in ACTIONS:
      result[route][a] = %*{"name": %(a & capitalize tabName)}


proc updateDefinition*(appState: JsonNode) =
  ## Recieves an ui-definition and updates it
  ## filling the blanks with the model

  var uiBody = appState["definition"]["body"]
  for routes, content in uiBody.getFields:
    # first level are the routes
    var modelName: string
    if content.hasKey "model":
      modelName = content["model"].getStr
      # delete, we won't be using afterwards
      content.delete "model"
    for action, def in content.getFields:
    # if the definition does not have children create them from model.js
      if not def.hasKey "model": def["model"] = %modelName
      if def.kind == JObject and not (def.hasKey "children") and
         appState["schema"].hasKey modelName:
        case action
        of "edit":
          editModel(appState, def)
        of "list":
           listModel(appState, def)
        of "show":
          showModel(appState, def)
          
        
