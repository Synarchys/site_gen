
import json, jsffi, tables

include karax / prelude 
import karax / vdom

proc attachEvents*(component: VNode, id:kstring, events: Table[kstring, JsObject]) =  
  if events.hasKey(id):
    let event = events[id]
    
    if jsTypeOf(event[$EventKind.onclick]) == "function":
      addEventHandler(component, EventKind.onclick, proc(ev: Event, n: VNode) = event.onclick(ev, n))
      
    if jsTypeOf(event[$EventKind.onchange]) == "function":
      addEventHandler(component, EventKind.onchange, proc(ev: Event, n: VNode) = event.onchange(ev, n))
