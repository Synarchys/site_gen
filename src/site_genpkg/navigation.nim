
import json, tables, strutils, times
import uuidjs


var history = %*{}

proc newView(action, model, sourceId: string, payload: JsonNode, mode = ""):JSonNode =
  result  = %*{
    "id": %genUUID(),
    "action": %action,
    "model": %model,
    "source": %sourceid,
    "payload": payload
  }
  if mode != "": result["mode"] = %mode


proc initHistory*(appState: JsonNode) =
  let vid = genUUID()
  history[vid] = %*{"id": %vid, "action": appState["route"]}
  appState["view"] = %*{"id": %vid}


#[
Default navigation:
Show/Listadd relation) -> New(edit) -> Save
                                           |               
              Show <- List(add relation) <-
]#

proc navigate*(appState, payload: JsonNode, viewid: string): JsonNode =
  # `viewid` is where the actions come from
  # if we are going to show an action+model that does not exists
  #   create a new viewid and its navigations status and add it to the history
  # if it already exists, show it.

  # Types of Actions
  # there are two kinds of actions.
  # - singular: `show`, `edit`, `list`
  #     do not depend on anything. go back to previous `viewid`.
  # - dependant:  `add`,`save`, `select`, `done`, `cancel`.
  #     are attached to a previous `viewid` and the behaivor is determined by the parent `viewid`.
  result = payload
  var
    model       = payload["model"].getStr
    action      = payload["action"].getStr
    sourceView  = history[viewid]
    targetView: JsonNode
    
  case action
  of "save", "select", "done", "cancel":
    targetView = history[sourceView["source"].getStr]
    
    if targetView.haskey "mode":
      result["mode"] = targetView["mode"]

    if not targetView.haskey "model":
      # ???
      # we are showing a msg o generic view, go to listing model.
      echo "WARNING: no model found at navigation."
      targetView = newView("list", model, sourceView["id"].getStr, payload)

    # goes to previous viewid, changes should be persisted.
    result["action"] = %action
    # after new -> select, go to grand parent
    if targetView.haskey("payload") and targetView["payload"].haskey "objid":
      result["parent"] = targetView["payload"]["objid"]
    
  of "delete":
    # do not redirect
    targetView = sourceView
    if targetView.haskey("payload") and targetView["payload"].haskey "objid":
      result["parent"] = targetView["payload"]["objid"]

  of "new", "show","edit", "list", "add":    
    if action == "add":
      action = "list"
      result["action"] = %action
      result["mode"] = %"select"
      
    elif action == "new":
      action = "edit"
      result["action"] = %action
      result["mode"] = %"new"
      
    else:
      result["mode"] = %action    
    # creates a new viewId
    targetView = newView(action, model, sourceView["id"].getStr, payload, result["mode"].getStr)   
    
  else:
    # show the same
    targetView = sourceView
    
  history[targetView["id"].getStr] = targetView
  appState["view"] = %*{"id": targetView["id"]}
  if result.haskey "mode":
    appState{"view", "mode"} = result["mode"]
                       
  let route = "#/$1/$2" % [targetView["model"].getStr, targetView["action"].getStr]
  appState["route"] = %route
