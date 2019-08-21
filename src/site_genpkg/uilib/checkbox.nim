
import tables
import karax / [vdom, karaxdsl]

import ../uielement

proc builder*(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml tdiv(class="form-group")
  var
    label = buildHtml label(class = "form-checkbox"): text el.label
    input = buildHtml input(`type`="checkbox", class = "form-input", id = el.id, placeholder = el.label)
    i = buildHtml italic(class="form-icon")
        
  input.addAttributes el
  input.addEvents wb, el
  
  label.add input
  label.add i
  result.add label


proc CheckBox*(id, label = ""): UiElement =
  result = newUiElement(UiElementKind.kCheckBox, events = @[UiEventKind.click])
  result.setAttribute("type", "checkbox")
  result.label = label
  result.id = id
  result.builder = builder
