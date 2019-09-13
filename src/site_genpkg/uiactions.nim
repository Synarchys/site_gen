# default actions for embeded ui components

import tables, json, strutils
import appcontext

proc loadDefaultActions*(app: var App, reRender: proc()) = 
  app.ctxt.actions.add "close_message",
     proc(payload: JsonNode) =
       echo payload.pretty
       if payload.haskey("objid"):
         let id = parseInt(payload["objid"].getStr)
         app.ctxt.messages.delete(id)
       reRender()
