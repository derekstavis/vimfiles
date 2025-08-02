; Pattern for generic function calls like evaluate<Type>()
((call_expression
  function: (await_expression
    (identifier) @_function)
  arguments: (arguments
    (template_string
      (string_fragment) @injection.content)))
 (#eq? @_function "evaluate")
 (#set! injection.language "python"))

; Pattern for generic function calls with regular strings
((call_expression
  function: (await_expression
    (identifier) @_function)
  arguments: (arguments
    (string
      (string_fragment) @injection.content)))
 (#eq? @_function "evaluate")
 (#set! injection.language "python"))

