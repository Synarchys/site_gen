
import tables

include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils
import webbuilder


proc buildButton*(wb: WebBuilder, el: UiElement, viewid: string): Vnode =
  result = buildHtml button(class="btn"): text el.label
  
  result.addAttributes el
  result.addEvents wb, el, viewid

