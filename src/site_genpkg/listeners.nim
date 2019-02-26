
import macros
import json, jsffi, tables, sequtils, strutils
import site_genpkg / ui_utils
import jsonflow, uuidjs


proc bindDataListners(ui: JsonNode, dataListeners: var Table[cstring, cstring]) =
  # bind procs that modify the ui state when data is changed
  # find components that have data listeners
  const key = "dataListeners"
  let elems = findElementsByAttrKey(ui, key)
  for elem in elems:
    let
      listener = elem["attributes"][key].getStr
      id = elem["id"].getStr
    dataListeners.add(listener, id)


proc callEventListener*(payload: JsonNode, action: cstring,
                       actions: Table[cstring, proc(payload: JsonNode){.closure.}]) =

  if actions.hasKey(action):
    var eventListener = actions[action]
    eventListener(payload)
  
  else:
    echo "WARNING: Action $1 not found in the table." % $action
    
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

 
proc processEventHandlers(n: NimNode): NimNode =  
  result = nnkStmtList.newTree(
    nnkVarSection.newTree(
      createEventsTable()
    )
  )

  for x in n:
    result.add addEventListener(x)

    
macro Listeners*(n: untyped): untyped =
  result = newStmtList()
  if n.kind == nnkStmtList:
    for x in n.children:
      if x.kind == nnkCall:
        if x[0].eqident("EventHandlers"):
          result.add x[1]
          result.add processEventHandlers(x[1])
          

