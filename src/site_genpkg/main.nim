
import json, tables, jsffi
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs, uuidjs

import builder

import site_genpkg / [content, menu, form, header, footer, grid, cards]
export content, menu, header, footer, grid, cards

var appState: JsonNode

# global variables
const headers = [(cstring"Content-Type", cstring"application/json")]
const definitionUrl = "/definition.json"
const modelUrl = "/model.json"


proc loadComponents(appState: JsonNode) =
  ajaxGet("/components.json",
          headers,
          proc(stat:int, resp:cstring) =
            appState["components"] = parseJson($resp)
            kxi.redraw()
  )


proc loadDefinition(appState: JsonNode) =
  ajaxGet(definitionUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appState["definition"] = parseJson($resp)
            kxi.redraw())


proc loadModel(appState: JsonNode) =
  ajaxGet(modelUrl,
          headers,
          proc(stat:int, resp:cstring) =
            appState["model"] = parseJson($resp)
            kxi.redraw())


proc lookUpAndUpdate*(id: kstring, data: JsonNode) =
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



proc MainContent(def: JsonNode): VNode =  

  let
    components = appState["components"]
    header = buildComponent(components["header"])
    menu = buildComponent(components["menu"])
    body = buildComponent(components["body"])
    
  result = buildHtml(tdiv()):
    header
    menu
    body
    Footer(def["footer"])

    
proc createDOM(data: RouterData): VNode =
  if not appState.hasKey("components"):
    loadComponents(appState)
    
  if not appState.hasKey("definition"):
    loadDefinition(appState)
    loadModel(appState)
    result = buildHtml(tdiv()):
      p:
        text "Loading Site..."
  else:
    result = MainContent(appState["definition"])


proc createApp*(state:JsonNode) =
  appState = state  
  setRenderer createDOM
