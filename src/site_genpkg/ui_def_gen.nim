## This module generates parts or the whole ui-definition based on the
## the model (the data schema).

import json, tables, unicode



proc editModel(appState, def: JsonNode) =
  let
    modelName = def["model"].getStr
    model = appState["model"][modelName] # must exist in the model
    
  var newV = def
  newV.add("children", %[])
  for field, fieldType in model.getFields:
    if field != "id" and fieldType.getStr == "string":
      newV["children"].add(
        %*{
          "name": %(field),
          "label": %(capitalize field), # uppercase first character
          "type": fieldType,
          "ui-type": %"input"
      })

  # default submit button
  newV["children"].add(
    %*{
      "name": %("save_button"),
      "ui-type": %"button",
      "label": %"Save",
      "events": %["onclick"]
  })


proc listModel(appState, def: JsonNode) =
  # use data to create the list
  echo "TODO: Create list definition."
  let
    modelName = def["model"].getStr
    model = appState["model"][modelName] # must exist in the model

  

proc showModel(appState, def: JsonNode) =
  echo "show the model"

  
proc updateDefinition*(appState: JsonNode) =
  ## Recieves an ui-definition and updates it
  ## feeling the blanks with the model

  # for the moment update the body part of the definition
  # as there is where all action is.
  
  var body = appState["definition"]["body"]
  for routes, content in body.getFields:
    # first level are the routes
    var model: JsonNode
    if content.hasKey("model"):
      model = content["model"]
      # delete, we won't be using afterwards
      content.delete "model"
    for action, def in content.getFields:  
    # if the definition does not have children create them from model.js
      if not def.hasKey("model"): def["model"] = model
      if def.kind == JObject and not def.hasKey("children"):
        case action
        of "edit":
          editModel(appState, def)
        of "list":
           listModel(appState, def)
        of "show":
          showModel(appState, def)
          
        
