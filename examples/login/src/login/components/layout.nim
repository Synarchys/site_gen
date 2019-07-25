
# Main site definition
import tables, json
import site_genpkg / [uielement, ui_utils, uilib, store]


proc Header(): UiElement =
  result = newUiElement(UiElementKind.kHeader)
  
  var
    navLinks = @[Link("Menu")]
    navSection = @[NavSection(navLinks)]
    nav = NavBar(navSection)  
  result.addChild nav

  
proc MainMenu(): UiElement =
  var menuItems = @[MenuItem("Primer elemento")]
  result = Menu("Home", menuItems)

  
proc LoginFrom(ctxt: AppContext): UiElement =
  result = newUiElement()
  
  var
    usrInp = InputText(label="User")
    passInp = InputText(label="Password")

  usrInp.setAttribute("model", "loginForm")
  usrInp.setAttribute("name", "user")
  usrInp.id = "loginForm"
  
  passInp.setAttribute("model", "loginForm")
  passInp.setAttribute("name", "password")
  passInp.id = "loginForm"
  
  result.render = proc(): UiElement =
    result = Form()
    var data = ctxt.getItem "loginForm"
    if not data.isNil:
      usrInp.value = data["user"].getStr
      passInp.value = data["password"].getStr
    
    result.addChild usrInp
    result.addChild passInp
    result.addChild Button("Login")
  
  
proc Body(ctxt: AppContext): UiElement =
  result = newUiElement(UiElementKind.kBody)  
  result.addChild LoginFrom(ctxt)
  
    
proc layout*(ctxt: AppContext): seq[UiElement] =
  result = @[]
  result.add Header()
  result.add MainMenu()
  result.add Body(ctxt)
