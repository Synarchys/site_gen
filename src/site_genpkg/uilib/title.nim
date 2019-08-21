
import site_genpkg / uielement
import karax / [vdom, karaxdsl]


proc builder(wb: WebBuilder, el: UiElement): Vnode =
  let s = el.getAttribute "size"
  case s
  of "1":
    result = buildHtml h1()
  of "2":
    result = buildHtml h2()
  of "3":
    result = buildHtml h3()
  of "4":
    result = buildHtml h4()
  of "5":
    result = buildHtml h5()
  of "6":
    result = buildHtml h6()
  else:
    result = buildHtml h1()

  let txt = buildHtml text(el.value)
  result.add txt
  result.addAttributes el
  result.addEvents wb, el
  

proc Title*(value = "", size="1"): UiElement =
  result = newUiElement(UiElementKind.kTitle)
  result.value = value
  result.builder = builder
  result.setAttribute "size", size

  
