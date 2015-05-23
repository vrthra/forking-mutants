$mypid = Process.pid
$parent_or_child = :parent
$decision_register = {}
$children = []
$mutant = 0 # parent

$operators=[
  [:==, :!=]
]

def triangle(a, b, c)
  if ((a + b) <= c) || ((a + c) <= b) || ((b + c) <= a)
    return :nottriangle
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
    if $decision_register[mutant].nil?
      $decision_register[mutant] = :!=
      child_id = fork
      if child_id.nil?
        $parent_or_child = :child
        $mutant = mutant
        # first time mutate, always
        return a.send($decision_register[mutant], b)
      else
        $children << child_id
        puts "forking #{child_id}"
        return a.send(op, b) # parent is always correct
      end
    else
      # this decision has already been made.
      return a.send(op, b)
    end
  when :child
    if $decision_register[mutant].nil?
      return a.send(op,b)
    else
      return a.send($decision_register[mutant], b)
    end
  end
end

def testit(&t)
  begin
    t.call()
    file = "log/_" + $mutant.to_s + "_" + Process.pid.to_s + ".alive"
    if $mypid != Process.pid
      File.open(file,'w+') do |f|
        f.puts $decision_register.to_s
      end
    end
  rescue => e
    file = ''
    if $mypid == Process.pid
      file = "parent" + ".log"
    else
      file = "log/_" + $mutant.to_s + "_" + Process.pid.to_s + ".dead"
    end
    File.open(file, 'w+') do |f|
      f.puts e.message
      f.puts e.backtrace
      f.puts $decision_register.to_s
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

