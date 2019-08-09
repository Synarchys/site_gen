
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
  var data = %*{"id": "showcaseDataId", "field1": "Field1 Value", "field2": "", "boolVal": true}
  addToStore(ctxt, data, "showcaseDataId")


proc updateLoginObj*(payload: JsonNode) =
  let
    id = payload["objid"].getStr
    value = payload["value"].getStr
    field = payload["node_name"].getStr

  echo payload.pretty
  setFieldValue(ctxt, id, field, value)
  #echo ctxt.state["store"].pretty  
  
  

