
import karax / [vdom, kdom, karaxdsl]

import site_genpkg / [uielement, appcontext]
import site_genpkg / uilib / [baseui, button]


proc builder(wb: WebBuilder, el: UiElement): VNode =
  result = buildHtml tdiv(class="toast"): text el.value
  result.addAttributes el
  
  
proc Message*(text: string, title, class, id = ""): UiElement =
  result = newUiElement(UiElementKind.kMessage)
  result.value = text
  result.builder = builder
  
  if class == "":
    result.setAttribute "class", "toast"
  else:
    result.setAttribute "class", "toast " & class
  
  if title != "":
    result.label = title
    
  var b = Button("")
  if id != "": b.id = id
  b.addEvent newUiEvent(UiEventKind.click, "close_message")
  b.setAttribute("class", "btn btn-clear float-right")
  result.add b
  
proc SuccessMessage*(text: string, title, id=""): UiElement =
  result = Message(text, title, "toast-success", id)

  
proc WarningMessage*(text: string, title, id=""): UiElement =
  result = Message(text, title, "toast-warning", id)

  
proc ErrorMessage*(text: string, title, id=""): UiElement =
  result = Message(text, title, "toast-error", id)


proc PrimaryMessage*(text: string, title, id=""): UiElement =
  result = Message(text, title, "toast-primary", id)


proc Message*(kind: MessageKind, text: string, title, id = ""): UiElement =
  
  case kind
  of MessageKind.success:
    result = SuccessMessage(text, title=title, id=id)

  of MessageKind.warning:
    result = WarningMessage(text, title=title, id=id)

  of MessageKind.error:
    result = ErrorMessage(text, title=title, id=id)
    
  of MessageKind.primary:
    result = PrimaryMessage(text, title=title, id=id)
    
  else:
    result = Message(text, title, id=id)
  

    
