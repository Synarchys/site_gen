
import site_genpkg / uielement
import karax / [vdom, karaxdsl]

# deprecate
proc buildRadio*(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml tdiv(class="form-group"):
    label(class = "form-label"):
      text el.label    
  
  for kid in el.children:
    if kid.kind == UiElementKind.kRadio:
      var
        formRadio = buildHtml label(class = "form-radio form-inline"):
          text kid.label
        input = buildHtml():
          input(`type`="radio", id = kid.id, value = kid.value)
        i = buildHtml italic(class="form-icon")
        
      input.addAttributes kid
      input.addEvents wb, kid

      formRadio.add input
      formRadio.add i
      result.add formRadio
      
  
proc Radio*(id, label = "", value=""): UiElement =
  result = newUiElement(UiElementKind.kRadio, events = @[UiEventKind.click])
  result.label = label
  result.id = id
  

proc RadioGroup*(id, label = ""): UiElement =
  result = newUiElement(UiElementKind.kRadioGroup)
  result.label = label
  result.id = id 
  result.builder = buildRadio
