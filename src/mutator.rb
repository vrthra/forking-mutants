require 'ripper'
require 'sorcerer'

class Mutator
  def initialize(srcf)
    @count = 1
    src = File.read(srcf)
    sexp = Ripper::SexpBuilder.new(src).parse
    @newsrc = Sorcerer.source(transform(sexp), multiline: true, indent: true)
  end

  def updated
    @newsrc
  end

  def transform(sexp)
    if sexp.class == Array
      if match(sexp)
        sexp = modify(sexp)
      end
      sexp.map do |s|
        transform(s)
      end
    else
      sexp
    end
  end

  def match(sexp)
    sexp[0] == :binary
  end

  def modify(sexp)
    b, arg1, op, arg2 = *sexp
    news = [:method_add_arg,
            [:fcall, [:@ident, "mutate", [1, 0]]],
            [:arg_paren,
             [:args_add_block,
              [:args_add, [:args_add, [:args_add, [:args_add, [:args_new],
                            [:@int, @count, [1, 7]]], arg1], arg2],
                 [:dyna_symbol, [:xstring_add, [:xstring_new],
                                 [:@tstring_content, op.to_s, [1, 17]]]]],
              false]]]
    @count += 1
    news
  end
end

#puts Mutator.new('src/triangle.rb').updated
