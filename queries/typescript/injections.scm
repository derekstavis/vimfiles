; extends
; Python passed to evaluate(), including awaited and generic calls.
((call_expression
  function: [
    (identifier) @_function
    (await_expression (identifier) @_function)
  ]
  arguments: (arguments
    [
      (template_string (string_fragment) @injection.content)
      (string (string_fragment) @injection.content)
    ]))
 (#eq? @_function "evaluate")
 (#set! injection.language "python"))
