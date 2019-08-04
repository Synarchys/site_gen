
import tables, strutils
include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils


proc buildLink*(el: UiElement, viewid: string): Vnode =  
  let action = el.getAttribute("action")
  var link = "#/" & el.value
  if action != "":
    link = link & "/" & action
    
  result = buildHtml():
    a(href=link, class="btn btn-link"): text el.label
  
