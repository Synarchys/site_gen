
import karax / [vdom, karaxdsl]

import baseui
import ../uielement


proc buildTable(wb: WebBuilder, el: UiElement): VNode =
  result = buildHtml table(class="table")
  var
    h = buildHtml thead()
    b = buildHtml tbody()

  for c in el.children:
    if c.kind == UiElementKind.kHeader:
      for hkid in c.children:
        var th = buildHtml th: text hkid.label
        h.add th
      result.add h
    break
  
  for c in el.children:
    if c.kind == UiElementKind.kRow:
      # iterate over the rows to create columns
      var row = buildHtml tr()
      for col in c.children:
        var htcol = buildHtml td():
          if not col.builder.isNil:
            col.builder(wb, col)
          else:
            text col.value
        
        row.add htcol
        if c.events.len > 0:
          row.class = "c-hand"
          row.addAttributes col

      row.addEvents wb, c
      b.add row
  result.add b


proc UiTable*(): UiElement =
  result = newUiElement(UiElementKind.kTable)
  result.builder = buildTable
