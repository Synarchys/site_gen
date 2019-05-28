
## This module generates parts or the whole ui-definition based on the
## the model (the data schema).
{.deprecated: "most of the code here should go to the specific components".}
import json, tables, unicode


proc editModel(appState, def: JsonNode) =
  let
    modelName = def["model"].getStr
    model = appState["schema"][modelName]
    
  var newV = def
  newV.add("children", %[])
  for field, fieldProps in model.pairs:
    if fieldProps.kind == JObject and fieldProps.hasKey "type":
      
      let fieldType = fieldProps["type"]
      # FIXME: all this code should go to the component
      # implement here how is input to be rendered
      # according to is type or if explicitly defined
      #if field != "id" and fieldType.getStr == "string":
      # move this code to edit-render

      if fieldType.getStr == "datetime":
        newV["children"].add(
          %*{
            "ui-type": %"datetime",
            "name": %field,
            "label": %(capitalize field), # uppercase first character
            "type": %"datetime",            
            "events": ["onkeyup"]
        })
      elif fieldType.getStr == "boolean":
        newV["children"].add(
          %*{
            "ui-type": %"check",
            "name": %field,
            "label": %(capitalize field), # uppercase first character
            "type": %"boolean",    
            "events": ["onclick"]
        })
      else:
        newV["children"].add(
          %*{
            "ui-type": %"input",
            "name": %field,
            "label": %(capitalize field), # uppercase first character
            "type": %"string",
            "events": ["onkeyup"]
        })
  
     
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
      result[route][a] = %*{"name": %(a & "_"  & tabName)}


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
