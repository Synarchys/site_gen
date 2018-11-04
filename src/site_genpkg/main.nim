
import json, tables
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs

import site_genpkg / [content, menu, header, footer]

const headers = [(cstring"Content-Type", cstring"application/json")]
const layout_def = "/definition.json"
var siteDef: JsonNode


proc loadDefinition() =
  ajaxGet(layout_def,
          headers,
          proc(stat:int, resp:cstring) =
            siteDef = parseJson($resp)
            kxi.redraw()

  )


proc MainContent(def: JsonNode): VNode =
  result = buildHtml(tdiv()):
    Menu(def["menu"])
    Header(def["header"])
    Content(def["body"])
    Footer(def["footer"])

    
proc createDOM(data: RouterData): VNode =
  if siteDef.isNil:
    loadDefinition()
    result = buildHtml(tdiv()):
      p:
        text "Loading site..."
  else:
    result = MainContent(siteDef)

    
proc createApp*() =
  setRenderer createDOM
