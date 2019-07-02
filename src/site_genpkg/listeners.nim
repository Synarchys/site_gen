
import macros
import json, jsffi, tables, sequtils, strutils
import site_genpkg / ui_utils
import jsonflow, uuidjs


proc noEventListener(payload: JsonNode, action: string): proc(payload: JsonNode){.closure.} =
  result = proc(payload: JsonNode){.closure.} =
    echo "WARNING: Action $1 not found in the table." % $action

    
proc callEventListener*(payload: JsonNode,
                        actions: Table[cstring, proc(payload: JsonNode){.closure.}]) =

  var eventListener: proc(payload: JsonNode){.closure.}
  var a: string
  if payload.haskey("node_name"):
    a = payload["node_name"].getStr
  elif payload.haskey("action"):
    a = payload["action"].getStr

  let
    nodeKind = payload["node_kind"].getStr
    eventKind = payload["event_kind"].getStr.replace("on", "")
    defaultNodeAction = "default_action_" & nodeKind & "_" & eventKind
    sitegen_action = "$1_$2_$3" % [payload["model"].getStr, a, eventKind]


  if actions.hasKey sitegen_action:
    eventListener = actions[sitegen_action]
  elif actions.hasKey defaultNodeAction:
    eventListener = actions[defaultNodeAction]
  elif actions.hasKey "sitegen_default_action":
    # default action
    eventListener = actions["sitegen_default_action"]
  else:
    eventListener = noEventListener(payload, sitegen_action)
  eventListener payload

  
proc createEventsTable(): NimNode =
  result = nnkIdentDefs.newTree(
    nnkPostfix.newTree(
      newIdentNode("*"),
      newIdentNode("actions")
    ),
    newEmptyNode(),
    nnkCall.newTree(
      nnkBracketExpr.newTree(
        newIdentNode("initTable"),
        newIdentNode("cstring"),
        nnkProcTy.newTree(
          nnkFormalParams.newTree(
            newEmptyNode(),
            nnkIdentDefs.newTree(
              newIdentNode("payload"),
              newIdentNode("JsonNode"),
              newEmptyNode()
            )
          ),
          nnkPragma.newTree(
            newIdentNode("closure")
          )
        )
      )
    )
  )


proc addEventListener(n: NimNode): NimNode =  
  result = nnkCall.newTree(
    nnkDotExpr.newTree(
      newIdentNode("actions"),
      newIdentNode("add")
    ),
    nnkCallStrLit.newTree(
      newIdentNode("cstring"),      
      newLit($n[0].ident)
    ),
    newIdentNode($n[0].ident)
  )


macro EventHandlers*(n: untyped): untyped =
  # actions table
  result = nnkStmtList.newTree(
    nnkVarSection.newTree(
      createEventsTable()
    )
  )
  
  if n.kind == nnkStmtList:
    for x in n.children:
      result.add x
      if x.kind == nnkProcDef:
        result.add addEventListener(x)

 
