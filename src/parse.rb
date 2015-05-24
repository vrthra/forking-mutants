require 'ripper'
require 'sorcerer'
require 'ap'

def transform(sexp)
  if sexp.class == Array
    if match(sexp)
      sexp = mytransform(sexp)
    end
    sexp.map do |s|
      transform(s)
    end
  else
    sexp
  end
end

def match(sexp)
  case sexp[0]
  when :binary
    return true
  else
    return false
  end
end

# [:program,
#   [:stmts_add,
#     [:stmts_new],
#     [:binary,
#       [:vcall, [:@ident, "a", [1, 0]]],
#       :"&&",
#       [:vcall, [:@ident, "b", [1, 5]]]]
#   ]
# ]

# [:program,
#   [:stmts_add,
#     [:stmts_new],
#     [:method_add_arg,
#       [:fcall, [:@ident, "mutate", [1, 0]]],
#       [:arg_paren,
#         [:args_add_block,
#           [:args_add,
#             [:args_add,
#               [:args_add,
#                 [:args_add, [:args_new], [:@int, "1", [1, 7]]],
#                 [:vcall, [:@ident, "a", [1, 10]]]
#               ],
#               [:vcall, [:@ident, "b", [1, 13]]]
#             ],
#             [:dyna_symbol, [:xstring_add, [:xstring_new], [:@tstring_content, "&&", [1, 17]]]]
#           ], false
#         ]
#       ]
#     ]
#   ]
# ]

$count = 1
def mytransform(sexp)
  b, arg1, op, arg2 = *sexp
  news = [:method_add_arg,
       [:fcall, [:@ident, "mutate", [1, 0]]],
       [:arg_paren,
         [:args_add_block,
           [:args_add,
             [:args_add,
               [:args_add,
                 [:args_add, [:args_new], [:@int, $count, [1, 7]]],
                 arg1
               ],
               arg2
             ],
             [:dyna_symbol, [:xstring_add, [:xstring_new], [:@tstring_content, op.to_s, [1, 17]]]]
           ], false
         ]
       ]
     ]
  $count += 1
  news
end

src = File.read('src/triangle.rb')
sexp = Ripper::SexpBuilder.new(src).parse
#sexp = Ripper::SexpBuilder.new("mutate(1, a, b,:'&&')").parse
#sexp = transform(sexp)
puts Sorcerer.source(transform(sexp), multiline: true, indent: true)

