
# wrapps around `builder.nim` but uses uielement objects instead of json
import tables, json, strutils
import uuidjs

include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]
import uielement, builder, ui_utils, uitemplates


import components / uiedit


var
  defaultEvent: proc(name, id, viewid: string): proc(ev: Event, n: VNode)
  eventsMap: Table[uielement.UiEvent, EventKind]


proc buildTargetElement(n: var Vnode, el: UiElement, viewid: string) =
  #if not el.render.isNil: el.render()
  # sett events
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

    
proc buildLink(el: UiElement, viewid: string): Vnode = 
  result = buildHtml():
    let link = "#" & el.value
    a(href=link, class="btn btn-link"): text el.label
  result.buildTargetElement(el, viewid)


proc buildMenuItem(el: UiElement, viewid: string): Vnode =
  result = buildHtml():
    li(class="menu-item"):
      a:
        text el.value        
  result.buildTargetElement(el, viewid)


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


proc buildButton(el: UiElement, viewid: string): Vnode =
  result = buildHtml button(class="btn"): text el.label
  result.buildTargetElement(el, viewid)

  
proc buildInputText(el: UiElement, viewid: string): Vnode =
  result = buildHtml tdiv(class="form-group")
  var
    label = buildHtml label(class = "form-label", `for`= el.id): text el.label
    input = buildHtml input(class = "form-input", id = el.id, placeholder = el.label)
  
  input.buildTargetElement(el, viewid)
  result.add label
  result.add input


proc buildForm(f: UiElement, viewid: string): VNode =
  result = buildHtml():
    form()
  
  for c in f.children:    
    case c.kind:
      of UiElementKind.kInputText:
        result.add buildInputText(c, viewid)

      of UiElementKind.kButton:
        result.add buildButton(c, viewid)
        
      else:
        echo "Unknown UiElementkind."
        echo c.kind, " - ", c.label

  
proc buildBody(body: UiElement, viewid, route: string): VNode =    
  result = newVNode VnodeKind.tdiv

  var el = body
  if not el.render.isNil: el = el.render()
  
  if el.kind == UiElementKind.kForm:
    result.add buildForm(el, viewid)
  else:
    for l in el.children:
      var elkid = l
      if not l.render.isNil: elkid = l.render()
      result.add buildBody(elkid, viewid, route)

      
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
        result.add buildHeader(el, viewid)
      
      of UiElementKind.kMenu:
        result.add buildMenu(el, viewid)
      
      of UiElementKind.kBody:
        echo route, "/", action
        # use the correct ui for the action
        case action
        of "edit":
          # uiedit
          let ui = UiEdit(app.ctxt, viewid, route)
          result.add buildBody(ui, viewid, route)
        else:
          let cName = route.replace("#/", "")
          if cName != "":
            let ui = app.ctxt.uicomponents[cName].render()
            result.add buildBody(ui, viewid, route)
          else:
            echo "Error: Invalid Ui Component."

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
