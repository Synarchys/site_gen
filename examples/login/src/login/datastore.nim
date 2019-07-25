
import json, tables, sequtils, strutils, times, unicode
import site_genpkg / [appContext, store]


when defined(js):
  import uuidjs, asyncjs
else:
  import uuids, asyncnet, asyncdispatch, asyncfile


var
  ctxt: AppContext
  render: proc()


proc initStore*(appCtxt: var AppContext, reRender: proc()) {.async.} =
  render = reRender
  ctxt = appCtxt
  
  # add login Object to the store
  var loginForm = %*{"id": "loginForm", "user": "", "password": ""}
  addToStore(ctxt, loginForm, "loginForm")


proc updateLoginObj*(payload: JsonNode) =
  let
    id = payload["id"].getStr
    value = payload["value"].getStr
    field = payload["node_name"].getStr
    
  setFieldValue(ctxt, id, field, value)
  echo ctxt.state["store"].pretty  
  
  

