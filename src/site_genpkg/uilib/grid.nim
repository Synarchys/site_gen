
import karax / [kdom, vdom]

import site_genpkg / uielement
import site_genpkg / builder / webbuilder


proc buildGrid*(wb: WebBuilder, el: UiElement): VNode =
  result = buildHtml():
    tdiv(class="container"):
      tdiv(class="columns"):
        tdiv(class="column col-auto"): text "col-auto"
        tdiv(class="column": txt "col"


proc grid*(id = ""): UiElement =
  result = newUiElement(UiElementKind.kInputText)
  result.setAttribute("type", "text")
  if id != "":
    result.id = id
