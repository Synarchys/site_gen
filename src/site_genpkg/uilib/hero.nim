
import karax / [vdom, karaxdsl]
import ../uielement


proc builder(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml tdiv(class="hero")
  var b = buildHtml tdiv(class="hero-body")
  for c in el.children:
    b.add builder(wb, c)


proc Hero*(): UiElement =
  result = newUiElement(UiElementKind.kHero)
  result.builder = builder
