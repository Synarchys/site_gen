import json, jsffi
include karax / prelude 
import karax / prelude
import karax / [errors, kdom, vstyles]

import requestjs

import site_genpkg / main

const headers = [(cstring"Content-Type", cstring"application/json")]
const def_location = "/definition.json"

var console {.importcpp, noDecl.}: JsObject

var appStatus = %*{}
appStatus["data"] = %*{}

var gridRow =
  buildHtml(tdiv(class="row")):
    tdiv(class="col-sm"):
      input(`type`="checkbox", name="todoStatus")
    tdiv(class="col-sm"):
      text "content of the TODO"
      
var myGrid = 
  buildHtml(tdiv(class="container-fluid")):
    tdiv(class="row"):
      gridRow
    
var myGridJs = myGrid.toJson

myGridJs["children"][0]["children"][0]["children"][0]["events"] = %["onclick"]
myGridJs["children"][0]["children"][0]["children"][0]["name"] = %"gridRow"
myGridJs["children"][0]["children"][0]["children"][0]["dataListeners"] = %"renderMyGrid"

# TODO: grab model from the definition ?
myGridJs["children"][0]["children"][0]["children"][0]["model"] = %"todo"

appStatus["components"] = %*{
  "myGrid": myGridJs
}

createApp(appStatus)
