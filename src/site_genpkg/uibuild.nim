
# wrapps around `builder.nim` but uses uielement objects instead of json
import tables, json
import uuidjs

import karax / [kbase, kdom, vdom, karaxdsl]
import uielement, builder, ui_utils, uitemplates

var defaultEvent: proc(name, id, viewid: string): proc(ev: Event, n: VNode)
# defaultEvent = event

proc addEvent(n: var Vnode, viewid: string, el: UiElement) =  
  for evk in EventKind:
    if el.events.contains $evk:
      n.addEventListener evk, defaultEvent($evk, el.id, viewid)


proc buildLink(el: UiElement, viewid: string): Vnode = 
  result = buildHtml():
    a(href="#", class="btn btn-link"): text el.value
  result.addEvent(viewid, el)


proc buildMenuItem(el: UiElement, viewid: string): Vnode =
  result = buildHtml():
    li(class="menu-item"):
      a:
        text el.value        
  result.addEvent(viewid, el)
  
proc buildHeader(header: UiElement, viewid: string): VNode =
  result = buildHtml(header(class="navbar")):
    for men in header.children:
      if men.kind == UiElementKind.kNavBar:
        for sect in men.children:
          if sect.kind == UiElementKind.kNavSection:
            section(class="navbar-section"):
              for l in sect.children:
                if l.kind == UiElementKind.kLink:
                  buildLink(l, viewid)


proc buildMenu(menu: UiElement, viewid: string): VNode =
  result = buildHtml():
    ul(class="menu"):
      li(class="divider", data-content=menu.value)
      for menuItem in menu.children:
        buildMenuItem(menuItem, viewid)
  

proc toJson(e: UiElement): JsonNode =  
  case e.kind 
  of UiElementKind.kButton:
    result = copy templates["button"]
    result.setAttribute("class", "btn")
    result.setText e.value
                      
  of UiElementKind.kText:
    result = %*{"ui-type": %"#text", "text": %e.value}
  else:
    # TODO:
    echo "Error: Unoknown kind."

  for ev in e.events:
    result.addEvent ev
  
  for c in e.children:
    result.addChild c.toJson()


proc updateUI*(app: var App, event: proc(name, id, viewid: string): proc(ev: Event, n: VNode)): VNode =
  var
    state = app.ctxt.state
    view = state["view"]
    viewid = view["id"].getStr

  defaultEvent = event
  result = newVNode VnodeKind.tdiv
  result.class = "container"
  
  for el in app.layout:    
    case el.kind:
    of UiElementKind.kHeader:
      result.add buildHeader(el, viewid)
      
    of UiElementKind.kMenu:
      result.add buildMenu(el, viewid)
      
    of UiElementKind.kBody:
      for elkid in el.children:
        var ejs = elkid.toJson()
        result.add buildComponent(viewid, ejs, event)
  
    else:
      # TODO:
      echo "Error: Invalid Layout section."
