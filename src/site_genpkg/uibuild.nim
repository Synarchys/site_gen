
# wrapps around `builder.nim` but uses uielement objects instead of json
import tables, json, strutils
import uuidjs

include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import uielement, builder, ui_utils, uitemplates

# complex components
import components / uiedit
import uibuild / builders


var wb: WebBuilder


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
  try:
    if el.kind == UiElementKind.kComponent:
      if not el.builder.isNil:
        result = el.builder(wb, el)
      else:
        result = buildHtml(tdiv())
      result.addAttributes el
      
      for c in el.children:
        let vkid = buildElement(c, viewid)
        if not vkid.isNil:
          result.add vkid
    else:
      result = wb.callBuilder(el)
  except:
    # TODO:
    let msg = getCurrentExceptionMsg()
    echo el.kind
    echo msg
    result = buildHtml(tdiv):
      h3: text "Error: Element build fail: " & $el.kind
      p: text msg

        
proc buildBody(body: UiElement, viewid, route: string): VNode =    
  result = buildElement(body, viewid)

      
proc updateUI*(app: var App): VNode =
  var
    state = app.ctxt.state
    view = state["view"]
    viewid = view["id"].getStr
    route, action: string
  
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
    el.viewid = viewid
    # deprecate the use of render
    # if not el.render.isNil: el = l.render()
    case l.kind:
      of UiElementKind.kHeader:
        # TODO:
        discard
        # result.add wb.callBuilder(el)
      
      of UiElementKind.kMenu:
        result.add wb.callBuilder(el)
      
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
          let ui = app.ctxt.uicomponents[cName](app.ctxt)
          result.add buildBody(ui, viewid, route)

      else:
        # TODO:
        echo "Error: Invalid Layout section."


proc initApp*(app: var App, event: proc(uiev: uielement.UiEvent, el: UiElement, viewid: string): proc(ev: Event, n: VNode)): VNode =
  wb = initBuilder(event)
  result = updateUI(app)
