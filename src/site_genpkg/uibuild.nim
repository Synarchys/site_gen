
# wrapps around `builder.nim` but uses uielement objects instead of json
import tables, json, strutils
import uuidjs

include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import uielement, builder, ui_utils, uitemplates

# complex components
import components / uiedit

import uibuild / builders


var
  defaultEvent: proc(name, id, viewid: string): proc(ev: Event, n: VNode)
  eventsMap: Table[uielement.UiEvent, EventKind]
  webBuilders = getWebBuilders()


proc buildTargetElement(n: var Vnode, el: UiElement, viewid: string) =
  # set events
  for e in el.events:
    let kev = eventsMap[e]
    n.addEventListener kev, defaultEvent($kev, el.id, viewid)
    
  # set attributes
  for k, v in el.attributes.pairs:
    n.setAttr(k, v)
    
  # set value
  if n.kind == VnodeKind.input:
    setInputText n, el.value

  
proc toJson(e: UiElement): JsonNode = 
  case e.kind:
    of UiElementKind.kButton:
      result = copy templates["button"]
      result.setAttribute("class", "btn")
      result.setText e.label

    of UiElementKind.kText:
      result = %*{"ui-type": %"#text", "text": %e.label}
    else:
      # TODO:
      echo "Error: Unoknown kind."
  for ev in e.events:
    result.addEvent "on" & $ev
  for c in e.children:
    result.addChild c.toJson()

    
proc buildElement(uiel: UiElement, viewid: string): VNode =
  var el: UiElement = uiel   
  if not uiel.render.isNil: el = uiel.render()  
  if el.kind == UiElementKind.kComponent:
    # for now use its first child
    el = el.children[0]

  if webBuilders.hasKey el.kind:
    result = webBuilders[el.kind](el, viewid)
    result.buildTargetElement(el, viewid)
    
  else:
    result = buildElement(el, viewid)
    result.buildTargetElement(el, viewid)
    
  for elkid in el.children:
    result.add buildElement(elkid, viewid)
  
        
proc buildBody(body: UiElement, viewid, route: string): VNode =    
  result = newVNode VnodeKind.tdiv
  result.add buildElement(body, viewid)

      
proc updateUI*(app: var App, event: proc(name, id, viewid: string): proc(ev: Event, n: VNode)): VNode =
  var
    state = app.ctxt.state
    view = state["view"]
    viewid = view["id"].getStr
    route, action: string
  
  defaultEvent = event
  result = newVNode VnodeKind.tdiv
  result.class = "container"

  if state.hasKey("route") and state["route"].getStr != "":
    let splitRoute = state["route"].getStr.split "/"
    # just asume first item is `#`.
    # use `#` in the ui definition to know it is a route.
    route = splitRoute[0..1].join "/"
    if splitRoute.len > 2: action = splitRoute[2]
    
  for l in app.layout:
    var el = l
    if not el.render.isNil: el = l.render()
    case l.kind:
      of UiElementKind.kHeader:
        result.add webBuilders[UiElementKind.kHeader](el, viewid)
      
      of UiElementKind.kMenu:
        result.add webBuilders[UiElementKind.kHeader](el, viewid)
      
      of UiElementKind.kBody:
        # use the correct ui for the action
        case action
        of "edit":
          echo route, "/", action
          # uiedit
          let ui = UiEdit(app.ctxt, viewid, route)
          result.add buildBody(ui, viewid, route)
        else:
          let cName = route.replace("#/", "")
          if cName != "":
            let ui = app.ctxt.uicomponents[cName]
            result.add buildBody(ui, viewid, route)
          else:
            echo "Error: Invalid Action:" & action & "."
      else:
        # TODO:
        echo "Error: Invalid Layout section."


proc initApp*(app: var App, event: proc(name, id, viewid: string): proc(ev: Event, n: VNode)): VNode =
  defaultEvent = event
  for uie in uielement.UiEvent:
    for kev in EventKind:
      if $kev == ("on" & $uie):
        eventsMap.add(uie, kev)
        break
    
  result = updateUI(app, defaultEvent)
