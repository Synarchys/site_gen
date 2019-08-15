
import karax / [kdom, vdom]

import ../uielement
import webbuilder


proc buildGrid*(wb: WebBuilder, el: UiElement): VNode =
  result = buildHtml():
    tdiv(class="container"):
      tdiv(class="columns"):
        tdiv(class="column col-auto"): text "col-auto"
        tdiv(class="column": txt "col"

