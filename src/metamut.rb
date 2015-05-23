$mypid = Process.pid
$parent_or_child = :parent
$decision_register = {}
$children = []
$mutant = 0 # parent

$operators=[
  [:==, :!=]
]

$hash = {
  :== => [:!=],
  :!= => [:==],
}

def triangle(a, b, c)
  if ((a + b) <= c) || ((a + c) <= b) || ((b + c) <= a)
    return :notriangle
  elsif (mutate(a, b, 1, :==) && mutate(a, c, 2, :==) && mutate(b, c, 3, :==))
    return :equilateral
  elsif (mutate(a, b, 4, :==) || mutate(a, c, 5, :==) || mutate(b, c, 6, :==))
    return :isosceles
  else
    return :scalene
  end
end

def mutate(a, b, mutant, op)
  case $parent_or_child
  when :parent
    if not($decision_register[mutant].nil?)
      # this decision has already been made.
      return a.send(op, b)
    end
    opts = $hash[op]
    opts.each do |o|
      child_id = fork
      if child_id.nil?
        $decision_register[mutant] = o
        $parent_or_child = :child
        $mutant = mutant
        return a.send($decision_register[mutant], b)
      else
        puts "forking #{child_id}"
        $children << child_id
      end
    end
    $decision_register[mutant] = op
    return a.send(op, b) # parent is always correct
  when :child
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
      file = mutant_name + Process.pid.to_s + ".dead"
    end
    File.open(file, 'a+') do |f|
      f.puts "#{$mutant} #{$decision_register[$mutant]}"
      f.puts $decision_register.to_s
      f.puts e.message
      f.puts e.backtrace
    end
  end

  if $parent_or_child == :parent
    $children.each do |p|
      Process.wait p
    end
  end
end


def test_equilateral_triangles_have_equal_sides
  :equilateral == triangle(2, 2, 2) or raise "Equilateral 1 #{$mutant}"
  :equilateral == triangle(10, 10, 10) or raise "Equilateral 2 #{$mutant}"
end

def test_isosceles_triangles_have_exactly_two_sides_equal
  :isosceles == triangle(3, 4, 4) or raise "Isosceles 1 #{$mutant}"
  :isosceles == triangle(4, 3, 4) or raise "Isosceles 2 #{$mutant}"
  :isosceles == triangle(4, 4, 3) or raise "Isosceles 3 #{$mutant}"
  :isosceles == triangle(10, 10, 2) or raise "Isosceles 4 #{$mutant}"
end

def test_scalene_triangles_have_no_equal_sides
  :scalene == triangle(3, 4, 5) or raise "Scalene 1 #{$mutant}"
  :scalene == triangle(10, 11, 12) or raise "Scalene 2 #{$mutant}"
  :scalene == triangle(5, 4, 2) or raise "Scalene 3 #{$mutant}"
end

def test_triangle
  :notriangle == triangle(1,2,10) or raise "NoTriangle 1 #{$mutant}"
  :notriangle == triangle(1,10,2) or raise "NoTriangle 2 #{$mutant}"
  :notriangle == triangle(10,1,2) or raise "NoTriangle 3 #{$mutant}"
end

testit do
  test_equilateral_triangles_have_equal_sides
  test_isosceles_triangles_have_exactly_two_sides_equal
  test_scalene_triangles_have_no_equal_sides
  test_triangle
end

