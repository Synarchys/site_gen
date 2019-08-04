
include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils


proc buildButton*(el: UiElement, viewid: string): Vnode =
  result = buildHtml button(class="btn"): text el.label
  
