# TODO:

# add reference to layout and content definition (json)
# add here reference to dataflow handling
# add here reference to service clent layer(rest/ws)

import json
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, kajax, vstyles]

import site_genpkg / [content, menu, header, footer]

const headers = [(cstring"Content-Type", cstring"application/json")]
const layout_def = "/definition.json"
var siteDef: JsonNode
  
proc loadDefinitions() =
  ajaxGet(layout_def,
          headers,
          proc(stat:int, resp:cstring) =
            siteDef = parseJson($resp)
  )

proc MainContent(def: JsonNode): VNode =
  result = buildHtml(tdiv()):
    Menu(def["menu"])
    Header(def["header"])
    Content(def["body"])
    Footer(def["footer"])
    
proc createDOM(data: RouterData): VNode =
  if siteDef.isNil:
    loadDefinitions()
    result = buildHtml(tdiv()):
      p:
        text "Loading site..."
  else:
    result = MainContent(siteDef["definition"]["layout"])

    
setRenderer createDOM
