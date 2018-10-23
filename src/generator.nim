
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, kajax, vstyles]

import sugar, json

import ./components / [sections, menu, header, footer]

const headers = [(cstring"Content-Type", cstring"application/json")]

const agencyJS = "https://cdnjs.cloudflare.com/ajax/libs/startbootstrap-agency/5.0.2/js/agency.js"
var siteDef: JsonNode
#var d: JsonNode
  
proc loadData() =
  ajaxGet("../definition.json",
          headers,
          proc(stat:int, resp:cstring) =
            siteDef = parseJson($resp)
  )

proc MainContent(def: JsonNode): VNode =
  result = buildHtml(tdiv()):
    Menu(def["menu"])
    Header(def["header"])
    Sections(def["body"])
    Footer(def["footer"])
    script( src="js/agency.js")
    
proc createDOM(data: RouterData): VNode =
  if siteDef.isNil:
    loadData()
    result = buildHtml(tdiv()):
      p:
        text "Loading site..."
      script( src=agencyJS)
  else:
    result = MainContent(siteDef["definition"]["layout"])
        
    
setRenderer createDOM
