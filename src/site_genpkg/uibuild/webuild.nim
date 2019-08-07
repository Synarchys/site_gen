
# import tables

# include karax / prelude
# import karax / [kbase, kdom, vdom, karaxdsl]

# import ../uielement, ../ui_utils


# type
#   WebBuilder* = object
#     build*: proc(n: var Vnode, el: UiElement, viewid: string)
#     defaultEvent: proc(name, id, viewid: string): proc(ev: Event, n: VNode)
#     eventsMap: Table[uielement.UiEvent, EventKind]


# proc buildTargetElement(n: var Vnode, el: UiElement, viewid: string) =
#   # set events
#   for e in el.events:    
#     let kev = eventsMap[e]
#     n.addEventListener kev, defaultEvent($kev, el.id, viewid)
    
#   # set attributes
#   for k, v in el.attributes.pairs:
#     n.setAttr(k, v)

#   # set value
#   if n.kind == VnodeKind.input:
#     setInputText n, el.value

# # proc initWebBuilder(defaultEvent: proc(name, id, viewid: string): proc(ev: Event, n: VNode),
# #      eventsMap: Table[uielement.UiEvent, EventKind]): WebBuilder =
    
# #   result = WebBuilder()
  
# #   result.build = buildTargetElement
    

