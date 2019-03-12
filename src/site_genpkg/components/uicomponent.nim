
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
    render*: proc(lib, payload: JsonNode): JsonNode
    state*: JsonNode
    actions*: Table[cstring, proc(payload: JsonNode){.closure.}]

