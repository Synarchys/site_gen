## This module generates parts or the whole ui-definition based on the
## the model (the data schema).

import json, tables, unicode


proc updateDefinition*(appState: JsonNode) =
  ## Recieves an ui-definition and updates it
  ## feeling the blanks with the model

  # for the moment update the body part of the definition
  # as there is where all action is.
  
  var body = appState["definition"]["body"]
  for routes, content in body.getFields:
    # first level are the routes
    for k,v in content.getFields:
    # if v does not have children create them from model.js
      if v.kind == JObject and not v.hasKey("children"):
        if k == "edit":
          let
            modelName = v["model"].getStr
            model = appState["model"][modelName] # must exist in the model
          var newV = v
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

          newV["children"].add(
            %*{
              "name": %("save_button"),
              "ui-type": %"button",
              "label": %"Save",
              "events": %["onclick"]
          })
