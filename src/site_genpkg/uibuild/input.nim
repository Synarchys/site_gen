
include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils


proc buildInputText*(el: UiElement, viewid: string): Vnode =
  result = buildHtml tdiv(class="form-group")
  var
    label = buildHtml label(class = "form-label", `for`= el.id): text el.label
    input = buildHtml input(class = "form-input", id = el.id, placeholder = el.label)
    
  setInputText input, el.value
  result.add label
  result.add input
