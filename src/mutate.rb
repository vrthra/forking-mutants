$LOAD_PATH.unshift "./src"
require 'mutator'
case ARGV[0]
when /-src/
  puts Mutator.new(ARGV[1]).updated
when /-count/
  puts Mutator.new(ARGV[1]).counter
else
  puts "./mutator.rb [-src|-count]"
end
