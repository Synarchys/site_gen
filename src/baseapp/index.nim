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

createApp(appStatus)
