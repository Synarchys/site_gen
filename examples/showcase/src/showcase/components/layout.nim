
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
  var menuItems = @[MenuItem("Menu Link")]
  result = Menu("Home", menuItems)

  
proc Body(ctxt: AppContext): UiElement =
  result = newUiElement(UiElementKind.kBody)  

    
proc layout*(ctxt: AppContext): seq[UiElement] =
  result = @[]
  result.add Header()
  result.add MainMenu()
  result.add Body(ctxt)
