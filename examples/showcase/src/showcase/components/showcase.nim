
import tables, json
import site_genpkg / [uielement, ui_utils, uilib, store]


proc ShowCase*(ctxt: AppContext): UiElement =
  result = newUiElement(UiElementKind.kComponent)
  var form = Form()

  # input text
  var inputTxt = InputText(id = "showcaseDataId", label="Input Text")
  inputTxt.setAttribute("model", "showcaseData")
  inputTxt.setAttribute("name", "field1")
  
  # checkBox
  var cb = CheckBox(id="cb", "Checkbox")
  form.addChild cb
  
  var data = ctxt.getItem "showcaseDataId"
  
  if not data.isNil:
    inputTxt.value = data["field1"].getStr

  # dropdown
  var
    dd = Dropdown()
    ddi1 = DropdownItem("Chose One")
    ddi2 = DropdownItem("Slack")
    ddi3 = DropdownItem("Skype")
    ddi4 = DropdownItem("Hipchat")

  dd.children = @[ddi1, ddi2, ddi3, ddi4]
  form.add dd
  
  form.addChild inputTxt
  form.addChild Button("Action")
  result.addChild form
  
  # panel
  var
    p = Panel()
    pHeader = Header()
    pBody = Body()
    pFooter = Footer()

  p.label = "Content"
  pHeader.label = "Header"
  p.add pHeader

  pFooter.add Button("Panel Button")
  p.add pFooter
  
  result.add p
 
    
