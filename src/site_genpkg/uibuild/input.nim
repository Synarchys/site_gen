
import tables
include karax / prelude

import karax / [kdom, vdom]

import ../uielement, ../ui_utils
# import webbuilder


proc buildInputText*(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml tdiv(class="form-group")
  var
    label = buildHtml label(class = "form-label", `for`= el.id): text el.label
    input = buildHtml input(`type`= "text", class = "form-input", objid = el.id, placeholder = el.label)

  setInputText input, el.value
  input.addAttributes el
  input.addEvents wb, el
   
  result.add label
  result.add input

