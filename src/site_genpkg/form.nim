
import json

include karax / prelude 
import karax / [prelude, vstyles]


proc Input*(`type`="text", class, id, placeholder: kstring, aria_describedby=kstring""): VNode =
  result = buildHtml():
    input(`type`= `type`,
          id=id,
          class=class,
          aria-describedby=aria_describedby,
          placeholder=placeholder)


proc TextArea*(id:kstring, text="", rows=1): VNode =
  result = buildHtml():
   textarea(class="form-control", id=id, rows= $(rows))


proc Select*(id:kstring, data:JsonNode): VNode =
  # options is a JsArray of {id, value}
  result = buildHtml():
    select(class="form-control", id= id):    
      if not data.isNil:
        for opt in data.getElems:
          option: text opt["value"].getStr


proc FormField*(id: kstring,
                `type`="text",
                label="",
                text="",
                data:JsonNode=nil ,
                placeholder="",
                aria_describedby=""): VNode =
    
  result = buildHtml():
    tdiv(class="form-group"):
      label(`for`= id): text label
      if `type`== "text":
        Input(`type`=`type`,
              class="form-control",
              id=id,
              aria_describedby=aria_describedby,
              placeholder=placeholder)
        small(id=aria_describedby, class="form-text text-muted"):
          text text
      elif `type`=="textArea":
        TextArea(id=id, text=text)
      elif `type`=="select":
        Select(id=id, data=data)

        
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
          hint = if field.hasKey("hint"): field["hint"].getStr
                 else: field["name"].getStr
        
        var `type` = if field["type"].getStr == "text": "textArea"
                     elif field["type"].getStr == "string": "text"
                     else: field["type"].getStr

        var data = if field.hasKey("data"): field["data"]
                   else: nil
        FormField(id=field["id"].getStr,
                  `type`=`type`,
                  label=label,
                  text="",
                  placeholder=hint,
                  data=data,
                  aria_describedby=hint)
      Button()
