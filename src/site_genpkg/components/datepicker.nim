
import json, tables, sequtils, times, strutils
import ./uicomponent

proc getMonthWithDays(m: Month, year: int): OrderedTableRef[string, seq[int]] =  
  ## Returns an OrderdTable with the name of the day as key and a sequence with the day number for each day.
  ## Each day (mon to sun) has 5 day number, completed from previous or the next month if needed.
  
  var month = m
  result = newOrderedTable[string, seq[int]]()
  # initilize with days
  for wd in WeekDay:
    result[$wd] = newSeq[int]()

  let firstDayOfMonth = getDayOfWeek(1,month, year)

  # decrement one month to fill with days from the previous month
  dec month
  let
    daysInPrevMonth = getDaysInMonth(month, year)
    prevMonthFill = daysInPrevMonth + 1 - (ord(firstDayOfMonth)) # days to fill from previous month

  for prevD in prevMonthFill .. daysInPrevMonth:
    let prevWd = getDayOfWeek(prevD, month, year)
    result[$prevWd].add prevD
      
  # increment to the month we are interested in
  inc month
  for d in 1 .. getDaysInMonth(month, year):
    let dayOfWeek = getDayOfWeek(d, month, year)
    result[$dayOfWeek].add d

  # iterate over each day and if its length is less than 5 add values (from the next month)
  var lastDay = 1
  for k in WeekDay:
    if result[$k].len < 5:
      result[$k].add lastDay
      lastDay += 1


proc DateInput(components, data: JsonNode, date: string): JsonNode =
  var
    b = copy components["button"]
    i = copy components["input"]
  
  i["value"] = %date
  i["events"] = %[%"onkeyup"]
  b["id"] = %"datepicker_showdays"
  b["children"][0]["text"] = %"+"
  b["events"] = %[%"onclick"]
    
  result = %*{"ui-type": %"div", "children": %[]}
  result["children"].add i
  result["children"].add b


proc DaysTable(components, data: JsonNode, month: Month, year: int): JsonNode =
  let monthDays = getMonthWithDays(month, year)
  var
    row   = %*{"ui-type": %"tr", "children": %[]}
    tbody = %*{"ui-type": %"tbody", "children": %[]}
    th    = %*{"ui-type": %"th", "attributes": %*{"scope": %"col"}, "children": %[]}
    thead = %*{"ui-type": %"thead", "children": %[]}
    button = components["button"]

  result = %*{"ui-type": "table", "attributes": %*{"class": %"table"}, "children": %[]}
  # header columns 
  var hColumns = %[]
  for day in monthDays.keys:
    var
      ch = copy th
      day = %*{"ui-type": %"div", "children": %[%*{"ui-type": %"text", "text": %($(day[0]))}]}
    ch["children"].add day
    hColumns.add ch
  
  var hr = copy row
  hr["children"] = hColumns
  thead["children"].add hr
  result["children"].add thead

  #body
  for d in 0..4:
    var tr = copy row
    for wd in monthDays.keys:
      var
        td = %*{"ui-type": %"td", "children": %[]}
        txt = %*{"ui-type": %"#text", "text": %($monthDays[$wd][d])}
        a = %*{"ui-type": "a", "attributes":{"href": %"#"}, "children": %[txt]}
      a["events"] = %[%"oncklick"]
      td["children"].add a
      tr["children"].add td
    tbody["children"].add tr    
  result["children"].add tbody
  
  
proc Header(components, data: JsonNode): JsonNode =  
  result = %*{"ui-type": %"div", "children": %[]}
  for action in ["<", "Year Month", ">"]:
    var b = copy components["button"]
    b["children"][0]["text"] = %(action)
    b["events"] = %[%"onclick"]
    b["model"] = %"date_picker"
    b["name"] = %"encrease_decrease"
    #b["id"] = %"increase_decrease"    
    result["children"].add b

      
proc renderImpl(components, def: JsonNode, data: JsonNode = nil): JsonNode =
  result = %*{"ui-type": %"div", "children": %[]}
  # get the month and create the element
  var
    year = 2019
    month = mNov

  # from data we should get model 
  result["children"].add DateInput(components, data, "21/03/1998")
  result["children"].add Header(components, data)
  result["children"].add DaysTable(components, data, month, year)


var actions = initTable[cstring, proc(payload: JsonNode){.closure.}]()

type
  DatePicker* = object of BaseComponent

proc newDatePicker*(): DatePicker = 
  result = newBaseComponent(DatePicker, renderImpl)
