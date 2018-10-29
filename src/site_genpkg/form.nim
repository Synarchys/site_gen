
import json

include karax / prelude 
import karax / [prelude, vstyles]

proc Input*(`type`="text", class, id, aria_describedby="", placeholder: string): VNode =
  result = buildHtml():
    input(`type`= `type`,
          id=id,
          class=class,
          aria-describedby=aria_describedby,
          placeholder=placeholder)


proc TextArea*(id:string, text="", rows=1): VNode =
  result = buildHtml():
   textarea(class="form-control", id=id, rows= $(rows))

proc Select*(id:string, options: seq[string]): VNode =
  result = buildHtml():
    select(class="form-control", id=id):
      for opt in options:
        option: text $opt
        
proc FormField*(id: string, `type`="text", label="", text="", placeholder="", aria_describedby=""): VNode =
  result = buildHtml():
    tdiv(class="form-group"):
      label(`for`= id): text label
      if `type`== "text":
        Input(`type`=`type`,
              class="form-control",
              id= id,
              aria_describedby=aria_describedby,
              placeholder=placeholder)
        small(id=aria_describedby, class="form-text text-muted"):
          text text
      elif `type`=="textArea":
        TextArea(id=id, text=text)
      elif `type`=="select":
        Select(id=id, options= @["1","2","3","4"])
        
proc Button*(`type`="submit", text="Submit", class="btn btn-primary"): VNode =
  result = buildHtml():
    button(`type`=`type`, class=class): text text

proc Form*(def: JsonNode): VNode =
  let formFields = def["fields"].getElems
  result = buildHtml():
    form():
      for field in formFields:
        let
          label = field["label"].getStr
          hint = field["hint"].getStr

        var `type` = if field["type"].getStr == "text": "textArea"
                     elif field["type"].getStr == "string": "text"
                     else: field["type"].getStr
        echo `type`
        FormField(id="emailInput",
                  `type`=`type`,
                  label=label,
                  text="",
                  placeholder=hint,
                  aria_describedby="emailHelp")
      Button()
