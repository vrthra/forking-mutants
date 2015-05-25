require 'drb'
$mypid = Process.pid
def is_parent?
  $mypid == Process.pid
end

$decision_register = {}
$children = []
$mutant = 0 # parent

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

def triangle(a, b, c)
  if mutate(1, mutate(2, (mutate(3, (mutate(4, a, b, :"+")), c, :"<=")), (mutate(5, (mutate(6, a, c, :"+")), b, :"<=")), :"|"), (mutate(7, (mutate(8, b, c, :"+")), a, :"<=")), :"|")
    return :notriangle
  elsif (mutate(9, mutate(10, (mutate(11, a, b, :"==")), (mutate(12, a, c, :"==")), :"&"), (mutate(13, b, c, :"==")), :"&"))
    return :equilateral
  elsif (mutate(14, mutate(15, (mutate(16, a, b, :"==")), (mutate(17, a, c, :"==")), :"|"), (mutate(18, b, c, :"==")), :"|"))
    return :isosceles
  else
    return :scalene
  end
end

$drb_m = nil
def mutate(mutant, a, b, op)
  if is_parent?
    if not($decision_register[mutant].nil?)
      # this decision has already been made.
      return a.send(op, b)
    end
    opts = $hash[op]
    opts.each do |o|
      child_id = fork
      if child_id.nil?
        $decision_register[mutant] = o
        $drb_m = DRbObject.new(nil, 'druby://localhost:9000')
        if $drb_m.killed?(mutant)
          # dont continue if this has already been killed
          exit(0)
        end
        $mutant = mutant
        return a.send($decision_register[mutant], b)
      else
        $children << child_id
      end
    end
    $decision_register[mutant] = op
    return a.send(op, b) # parent is always correct
  else # child
    o = $decision_register[mutant] || op
    return a.send(o,b)
  end
end

def testit(&t)
  mutant_name = "log/_" + $mutant.to_s +
    '.' + $decision_register[$mutant].object_id.to_s +
    "_"
  begin
    t.call()
    file = mutant_name + Process.pid.to_s + ".alive"
    if $mypid != Process.pid
      File.open(file,'w+') do |f|
        f.puts "#{$mutant} #{$decision_register[$mutant]}"
      end
    end
  rescue => e
    file = ''
    if Process.pid == $mypid
      file = "parent_" + $mypid.to_s + ".log"
    else
      $drb_m.killed($mutant)
      file = mutant_name + Process.pid.to_s + ".dead"
    end
    File.open(file, 'a+') do |f|
      f.puts "#{$mutant} #{$decision_register[$mutant]}"
      f.puts $decision_register.to_s
      f.puts e.message
      f.puts e.backtrace
    end
  end

  if is_parent?
    $children.each do |p|
      puts "waiting #{p}"
      Process.wait p
    end
  end
end

class MainTester
  def MainTester.test_equilateral_triangles_have_equal_sides
    :equilateral == triangle(2, 2, 2) or raise "Equilateral 1 #{$mutant}"
    :equilateral == triangle(10, 10, 10) or raise "Equilateral 2 #{$mutant}"
  end

  def MainTester.test_isosceles_triangles_have_exactly_two_sides_equal
    :isosceles == triangle(3, 4, 4) or raise "Isosceles 1 #{$mutant}"
    :isosceles == triangle(4, 3, 4) or raise "Isosceles 2 #{$mutant}"
    :isosceles == triangle(4, 4, 3) or raise "Isosceles 3 #{$mutant}"
    :isosceles == triangle(10, 10, 2) or raise "Isosceles 4 #{$mutant}"
  end

  def MainTester.test_scalene_triangles_have_no_equal_sides
    :scalene == triangle(3, 4, 5) or raise "Scalene 1 #{$mutant}"
    :scalene == triangle(10, 11, 12) or raise "Scalene 2 #{$mutant}"
    :scalene == triangle(5, 4, 2) or raise "Scalene 3 #{$mutant}"
  end

  def MainTester.test_triangle
    :notriangle == triangle(1,2,10) or raise "NoTriangle 1 #{$mutant}"
    :notriangle == triangle(1,10,2) or raise "NoTriangle 2 #{$mutant}"
    :notriangle == triangle(10,1,2) or raise "NoTriangle 3 #{$mutant}"
  end
  def MainTester.callit(arg)
    case arg
    when :test_equilateral
      test_equilateral_triangles_have_equal_sides
    when :test_isosceles
      test_isosceles_triangles_have_exactly_two_sides_equal
    when :test_scalene
      test_scalene_triangles_have_no_equal_sides
    else
      test_triangle
    end
  end
end

testit do
  puts "#{ARGV[0].to_i}"
  case ARGV[0].to_i
  when 0
    MainTester.callit(:test_notriangle)
  when 1
    MainTester.callit(:test_equilateral)
  when 2
    MainTester.callit(:test_isosceles)
  when 3
    MainTester.callit(:test_scalene)
  else
    puts "#{ARGV[0]} not understood"
  end
end

