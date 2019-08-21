
import site_genpkg / uielement
import karax / [vdom, karaxdsl]


proc builder(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml p: text el.value
  result.addAttributes el
  result.addEvents wb, el
  

proc Paragraph*(id, value = ""): UiElement =
  result = newUiElement(UiElementKind.kParagraph)
  result.value = value
  result.builder = builder
  
