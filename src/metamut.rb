$LOAD_PATH.unshift('./src')
require 'mutator'
require 'evaluator'

host = ENV['MHOST'] || 'localhost:9000'
$e = Evaluator.new(host)
def mutate(mutant, a, b, op)
  $e.mutate(mutant, a, b, op)
end

def main(original, test, arg)
  eval(File.read(test), TOPLEVEL_BINDING)
  eval(Mutator.new(original).updated, TOPLEVEL_BINDING)
  $e.testit do |m|
    testmain(arg, m)
  end
end

main(ARGV[0], ARGV[1], ARGV[2])

