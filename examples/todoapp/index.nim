import json
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]
import jsffi

import requestjs

import site_genpkg / main

const headers = [(cstring"Content-Type", cstring"application/json")]
const def_location = "/definition.json"

var console {.importcpp, noDecl.}: JsObject

var appState = %*{}
appState["data"] = %*{}


                     
# proc loadDefinition() =
#   ajaxGet(def_location,
#           headers,
#           proc(stat:int, resp:cstring) =
#             appState["definition"] = parseJson($resp)
#             kxi.redraw()
#   )

createApp(appState)
