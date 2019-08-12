

import karax / [vdom, karaxdsl]
import webbuilder, ../uielement


proc buildPanelNav(el: UiElementKind): Vnode =
  result = buildHtml tdiv(class="panel-nav")


proc buildChildren(parent: Vnode, wb: WebBuilder, el: UiElement) =
  for c in el.children:
    var vn = wb.build c
    if not vn.isNil:
      parent.add vn
  
  
proc buildPanel*(wb: WebBuilder, el: UiElement): Vnode =
  var b, h, f: VNode
  
  for c in el.children:
    if c.kind == UiElementKind.kHeader:
      h = buildHtml tdiv(class="panel-header"):
        tdiv(class="panel-title"): text el.label
      buildChildren(h, wb, c)
        
    if c.kind == UiElementKind.kBody:
      b = buildHtml tdiv(class="panel-body")
      buildChildren(b, wb, c)
      
    elif c.kind == UiElementKind.kFooter:
      f = buildHtml tdiv(class="panel-footer")
      buildChildren(f, wb, c)
  
  result = buildHtml():
    tdiv(class="panel"):
      if not h.isNil: h
      if not b.isNil: b
      if not f.isNil: f
        
      
