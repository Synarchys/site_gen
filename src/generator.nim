
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, kajax, vstyles]

import sugar, json

import ./components / [content, menu, header, footer]

const headers = [(cstring"Content-Type", cstring"application/json")]

var siteDef: JsonNode
var d:      JsonNode
  
proc loadData() =
  ajaxGet("../definition.json",
          headers,
          proc(stat:int, resp:cstring) =
            siteDef = parseJson($resp)
  )

proc MainContent(def: JsonNode): VNode =
  result = buildHtml(tdiv()):
    Header(def["header"])
    Content(def["body"])
    Footer(def["footer"])
    
proc createDOM(data: RouterData): VNode =
  if siteDef.isNil:
    loadData()
    result = buildHtml(tdiv()):
      p:
        text "Loading site..."
  else:
    result = MainContent(siteDef["definition"]["layout"])
        
    
setRenderer createDOM
