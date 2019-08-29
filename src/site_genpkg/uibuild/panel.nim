

import karax / [vdom, karaxdsl]
import ../uielement
# import webbuilder


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
        if el.label != "":
          tdiv(class="panel-title"): text el.label
      for hkid in c.children:
        if hkid.kind == UiElementKind.kTitle:
          var t = buildHtml tdiv(class="panel-title")
          t.add wb.build hkid
          h.add t
        else:
          h.add wb.build hkid
        
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
        
      
