require 'ripper'
require 'sorcerer'

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
puts Sorcerer.source(transform(sexp), multiline: true, indent: true)

