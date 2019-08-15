

import karax / [vdom, karaxdsl]
import ../uielement, ../ui_utils
#import webbuilder


proc buildForm*(wb: WebBuilder, el: UiElement): VNode =
  result = buildHtml(form())
