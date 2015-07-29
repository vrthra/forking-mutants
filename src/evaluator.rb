require 'drb'
class Evaluator
  def initialize(host)
    @host = "druby://#{host}"
    @drb_m = nil
    @mypid = Process.pid
    @decision_register = {}
    @children = []
    @mutant = 0 # parent
    operators=[
      [:==, :!=],
      [:*, :/],
      [:'|', :'&'],
      [:'+', :'-'],
      [:'<=', :'>='],
      [:'<', :'>'],
    ]

    @hash = {}
    operators.each do |lst|
      lst.each do |o|
        @hash[o] = lst - [o]
      end
    end
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
      opts = @hash[op]
      opts.each do |o|
        child_id = fork
        if child_id.nil?
          @decision_register[mutant] = o
          @drb_m = DRbObject.new(nil, @host)
          while true
            begin
              @drb_m.killed?(0)
              break
            rescue DRb::DRbConnError => e
              sleep 1
            end
          end
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
      # TODO: remove this.
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
      DRbObject.new(nil, @host).bye
    end
  end
end
