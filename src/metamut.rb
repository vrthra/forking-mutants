$LOAD_PATH.unshift('./src')
require 'drb'
require 'mutator'

$operators=[
  [:==, :!=],
  [:'|', :'&'],
  [:'+', :'-'],
  [:'<=', :'>='],
]

$hash = {}
$operators.each do |lst|
  lst.each do |o|
    $hash[o] = lst - [o]
  end
end

class Evaluator
  def initialize(host)
    @drb_m = nil
    @mypid = Process.pid
    @decision_register = {}
    @children = []
    @mutant = 0 # parent
    @host = host
  end
  def is_parent?
    @mypid == Process.pid
  end
  def mutate(mutant, a, b, op)
    if is_parent?
      if not(@decision_register[mutant].nil?)
        # this decision has already been made.
        return a.send(op, b)
      end
      opts = $hash[op]
      opts.each do |o|
        child_id = fork
        if child_id.nil?
          @decision_register[mutant] = o
          @drb_m = DRbObject.new(nil, "druby://#{@host}")
          @mutant = mutant
          if @drb_m.killed?(@mutant)
            # dont continue if this has already been killed
            raise "killed"
          end
          return a.send(@decision_register[mutant], b)
        else
          @children << child_id
        end
      end
      @decision_register[mutant] = op
      return a.send(op, b) # parent is always correct
    else # child
      o = @decision_register[mutant] || op
      return a.send(o,b)
    end
  end

  def testit(&t)
    begin
      t.call(@mutant)
    rescue => e
      if e.message !~ /equilateral|isosceles|scalene|notriangle|killed/
        puts e.message
        puts e.backtrace
      end
      if Process.pid != @mypid
        @drb_m.killed(@mutant)
      end
    end

    if is_parent?
      @children.each do |p|
        puts "waiting #{p}"
        Process.wait p
      end
      DRbObject.new(nil, "druby://#{@host}").bye
    end
  end
end

$host = ENV['MHOST'] || 'localhost:9000'
$e = Evaluator.new($host)
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

