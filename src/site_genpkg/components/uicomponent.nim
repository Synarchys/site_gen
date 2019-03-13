
# This module defines the type for the base ui component.
# The ui component is used to isolate ui elements and its events when needed for complex components

# TODO
# Add macro to simplify component coding
# UiComponent:
#   proc render(payload: JsonNode) =
#     echo "your json processing goes here"
#  
#   Events:
#     proc handle_some_event(payload: JsonNode) =
#       echo "your event handler comes here"

import json, tables

type
  BaseComponent* = object of RootObj
    renderImpl*: proc(lib, def: JsonNode, data: JsonNode = nil): JsonNode
    actions*: Table[cstring, proc(payload: JsonNode){.closure.}]


template newBaseComponent*[T](t: typeDesc[T],
                             render: (proc(lib, def: JsonNode, data: JsonNode = nil): JsonNode)): T =
  T(renderImpl: render)
                              
