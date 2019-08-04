

include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils


proc buildForm*(f: UiElement, viewid: string): VNode =
  result = buildHtml(form())
