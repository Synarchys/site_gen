
import json, tables, jsffi
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs

import site_genpkg / [content, menu, header, footer]

# consts
const headers = [(cstring"Content-Type", cstring"application/json")]
const layout_def = "/definition.json"

# global variables
var appState: JsonNode
var events: Table[kstring, JsObject]


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
  result = buildHtml(tdiv()):
    Menu(def["menu"])
    Header(def["header"])
    Content(def["body"], events)
    Footer(def["footer"])

    
proc createDOM(data: RouterData): VNode =
  if not appState.hasKey("definition"):
    events["init"].loadDefinition(appState)
    result = buildHtml(tdiv()):
      p:
        text "Loading site..."
  else:
    result = MainContent(appState["definition"])


proc createApp*(state:JsonNode, e: Table[kstring, JsObject]) =
  events = e
  appState = state
  # let ev = events["selectDepartamento"]
  # echo jsTypeOf(ev["onclick"])
  setRenderer createDOM
