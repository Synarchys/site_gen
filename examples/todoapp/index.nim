import json, jsffi
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs

import site_genpkg / main

const headers = [(cstring"Content-Type", cstring"application/json")]
const def_location = "/definition.json"

var console {.importcpp, noDecl.}: JsObject

var appState = %*{}
appState["data"] = %*{}

var myGrid = 
  buildHtml(tdiv(class="container-fluid")):
    tdiv(class="row"):
      tdiv(class="col-sm"):
        input(`type`="checkbox", value="some text")
      tdiv( class="col-sm"):
        text "content of the TODO"


var myGridJs = myGrid.toJson

myGridJs["children"][0]["children"][0]["events"] = %["onclick", "onchange"]
myGridJs["children"][0]["children"][0]["name"] = %"gridRow"
# TODO: grab model from the definition maybe
myGridJs["children"][0]["children"][0]["model"] = %"todo"

appState["components"] = %*{
  "myGrid": myGridJs
}

createApp(appState)
