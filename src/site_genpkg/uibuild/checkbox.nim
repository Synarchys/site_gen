
include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils


proc buildCheckBox*(el: UiElement, viewid: string): Vnode =
  result = buildHtml tdiv(class="form-group")
  var
    label = buildHtml label(class = "form-checkbox")
    input = buildHtml input(`type`="checkbox", class = "form-input", id = el.id, placeholder = el.label)
    i = buildHtml():
      italic(class="form-icon"): # karax node
        text el.label

  setInputText input, el.value
  label.add input
  label.add i
  result.add label
