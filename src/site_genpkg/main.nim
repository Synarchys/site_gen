
import json, tables, jsffi
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs, uuidjs

import builder
export builder

var appState: JsonNode

# global variables
const headers = [(cstring"Content-Type", cstring"application/json")]
const definitionUrl = "/definition.json"
const modelUrl = "/model.json"


# TODO:
# attach event handlers

proc loadDefinition(appState: JsonNode) =
  ajaxGet(definitionUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appState["definition"] = parseJson($resp)
            # finally we redraw when we have everything loaded
            kxi.redraw())

  
proc loadModel(appState: JsonNode) =
  ajaxGet(modelUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appState["model"] = parseJson($resp)
            loadDefinition(appState))

  
proc loadComponents(appState: JsonNode) =
  ajaxGet("/components.json",
          headers,
          proc(stat:int, resp:cstring) =
            let components = parseJson($resp)
            if appState.hasKey("components"):
              # merge components
              for k, v in components.getFields:
                if not appState["components"].hasKey(k):
                  # use components defined by the user if names colide
                  appState{"components", k}= v
            else:
              appState["components"] = components
            loadModel(appState))


proc lookUpAndUpdate*(id: kstring, data: JsonNode) =
  # FIXME: might not work as base code changed a lot
  # lookups for component in the definition tree
  # and updates de data attached to it
  let definition = appState["definition"]
  if definition.hasKey("body"):
    let body = definition["body"]
    if body.hasKey("children"):
      for child in body["children"].getElems:
        # lookup logic is too tied to definition structure
        if child.hasKey("form"):
          let form = child["form"]
          # it is a form it must contain a list of fields
          if form.hasKey("fields"):
            for field in form["fields"].getElems:
              if id == field["id"].getStr:
                field["data"] = data


proc createDOM(data: RouterData): VNode =
  if not appState.hasKey("definition"):
    result = buildHtml(tdiv()):
      p:
        text "Loading Site..."
  else:
    result = buildApp(appState)
    appState["ui"] = result.toJson
    #echo appState["ui"]


proc createApp*(state:JsonNode) =
  appState = state
  loadComponents(appState)
  setRenderer createDOM
