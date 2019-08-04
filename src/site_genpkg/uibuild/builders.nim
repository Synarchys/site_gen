
import tables
import karax / vdom
import ../uielement

# import modular builders 
import input, button, form, header, input, link, menu, checkbox


proc getWebBuilders*(): Table[UiElementkind, proc(el: UiElement, viewid: string): VNode] =
  result = initTable[UiElementkind, proc(el: UiElement, viewid: string): VNode]()
  result.add UiElementKind.kForm, buildForm
  result.add UiElementKind.kInputText, buildInputText
  result.add UiElementKind.kLink, buildLink
  result.add UiElementKind.kButton, buildButton
  result.add UiElementKind.kHeader, buildHeader
  result.add UiElementKind.kMenu, buildMenu
  result.add UiElementKind.kCheckBox, buildCheckBox
