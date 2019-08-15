
import tables, strutils
include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils
#import webbuilder


proc buildLink*(wb: WebBuilder, el: UiElement): Vnode =  
  let action = el.getAttribute("action")
  var link = "#/" & el.value
  if action != "":
    link = link & "/" & action
  result = buildHtml a(href=link, class="btn btn-link"): text el.label
  
  result.addAttributes el
  result.addEvents wb, el
