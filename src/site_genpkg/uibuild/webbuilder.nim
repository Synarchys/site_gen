
import tables
import karax / [vdom, kdom, karaxdsl]
import ../uielement


type
  WebBuilder* = object
    eventsMap*: Table[uielement.UiEventKind, EventKind]
    handler*: proc(uiev: uielement.UiEvent, el: UiElement, viewid: string): proc(ev: Event, n: VNode)
    builder*: proc(wb: WebBuilder, el: UiElement): VNode


proc build*(wb: WebBuilder, el: UiElement): VNode =
  result = wb.builder(wb, el)


proc addEvents*(n: var Vnode, wb: WebBuilder, el: UiElement) = 
  for ev in el.events:
    let targetKind = wb.eventsMap[ev.kind]
    n.addEventListener(targetKind, wb.handler(ev, el, el.viewid))


proc addAttributes*(n: var Vnode, el: UiElement) =
  for k, v in el.attributes.pairs:
    n.setAttr(k, v)


proc newWebBuilder*(handler: proc(uiev: uielement.UiEvent,
                                  el: UiElement, viewid: string): proc(ev: Event, n: VNode)): WebBuilder =
  result = WebBuilder()
  result.handler = handler
  
  for uievk in uielement.UiEventKind:
    for kev in EventKind:
      if $kev == ("on" & $uievk):
        result.eventsMap.add(uievk, kev)
        break

