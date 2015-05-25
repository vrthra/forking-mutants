require "minitest/unit"
require 'triangle'

#class Tester
#  def initialize
#    @tests = [
#      [:equilateral, [2, 2, 2]],
#      [:equilateral, [10, 10, 10]],
#      [:isosceles, [3, 4, 4]],
#      [:isosceles, [4, 3, 4]],
#      [:isosceles, [4, 4, 3]],
#      [:isosceles, [10, 10, 2]],
#      [:scalene, [3, 4, 5]],
#      [:scalene, [10, 11, 12]],
#      [:scalene, [5, 4, 2]],
#    ]
#  end
#  def test(arg, xinfo)
#    t = @tests[arg]
#    kind = t[0]
#    args = t[1]
#    kind == triangle(args[0], args[1], args[2]) or raise "#{kind} #{arg} #{xinfo}"
#  end
#end
#

class TestTriangle < MiniTest::Unit::TestCase
  def test_notriangle
    assert_equal(:notriangle, triangle(1,2,3))
    assert_equal(:notriangle, triangle(1,3,2))
    assert_equal(:notriangle, triangle(3,1,2))
    assert_equal(:notriangle, triangle(3,3,2))
  end
end


#def testmain(arg, info)
#  Tester.new().test(arg.to_i, info)
#end
#p MiniTest::Unit::TestCase.test_suites
#p TestTriangle.test_methods
# runner = MiniTest::Unit.new
# suite = TestTriangle.new("test_notriangle")
# p suite.run(runner)

runner = MiniTest::Unit.new
test = TestTriangle.new("test_notriangle")
p test.run(runner)

