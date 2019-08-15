
import tables
import karax / [vdom, karaxdsl]
import  ../uielement


proc buildButton*(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml button(class="btn"): text el.label
  
  result.addAttributes el
  result.addEvents wb, el

