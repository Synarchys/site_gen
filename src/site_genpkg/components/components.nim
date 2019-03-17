
import tables

import uicomponent, showmodel, listmodel, editmodel, datepicker
export uicomponent, showmodel, listmodel, editmodel, datepicker



proc initComponents*(): Table[string, BaseComponent] =
  result = initTable[string, BaseComponent]()
  result["edit"] = newEditModel()
  result["list"] = newListModel()
  result["show"] = newShowModel()

