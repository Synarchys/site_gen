
import tables
import karax / [vdom, kdom, karaxdsl]
import ../uielement

import webbuilder
export webbuilder

# import modular builders
import input, button, form, header, input, link, menu, checkbox

proc callBuilder*(wb: WebBuilder, elem: UiElement, viewid: string): VNode =
  var el = elem
   
  try:
    case el.kind
    of UiElementKind.kInputText:
      result = buildInputText(wb, el, viewid)
    of UiElementKind.kForm:
      result = buildForm(el, viewid)
    of UiElementKind.kLink:
      result = buildLink(wb, el, viewid)
    of UiElementKind.kButton:
      result = buildButton(wb, el, viewid)
    of UiElementKind.kHeader:
      result = buildHeader(wb, el, viewid)
    of UiElementKind.kMenu:
      result = buildMenu(el, viewid)
    of UiElementKind.kCheckBox:
      result = buildCheckBox(wb, el, viewid)
    else:
      echo "UnknownBuilder."
  except:
    # TODO:
    let msg = getCurrentExceptionMsg()
    echo el.kind
    echo msg
    
    result = buildHtml(tdiv):
      h3: text "Error: Element build fail: " & $el.kind
      p: text msg
    

proc initBuilder*(handler: proc(uiev: uielement.UiEvent, el: UiElement, viewid: string): proc(ev: Event, n: VNode)): WebBuilder =
  result = newWebBuilder(handler)
  result.builder = callBuilder
