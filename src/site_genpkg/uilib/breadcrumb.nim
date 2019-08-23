#breadcrumb component
import json
import ../uielement.nim
import karax / [kdom, vdom, karaxdsl]
import baseui


proc buildBreadcrumb(wb: WebBuilder, el: UiElement): Vnode =
  echo "build breadcrumb"
  result = buildHtml tdiv(class=""):
    ul(class="breadcrumb"):
      for child in el.children:
        echo child.value
        li(class="breadcrumb-item"):
          a(href="#"): text child.label
          

proc Breadcrumb*(): UiElement =
  echo "breadcrumb constructor"
  result = newUiElement(UiElementKind.kBreadcrum)
  result.builder = buildBreadcrumb
