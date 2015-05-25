$LOAD_PATH.unshift('./src')
require 'mutator'
require 'evaluator'

host = ENV['MHOST'] || 'localhost:9000'
$e = Evaluator.new(host)
def mutate(mutant, a, b, op)
  $e.mutate(mutant, a, b, op)
end

original = ARGV[0]
test = ARGV[1]
testarg = ARGV[2]

eval(File.read(test))
eval(Mutator.new(original).updated)

$e.testit do |m|
  testmain(testarg, m)
end

