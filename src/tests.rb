require "minitest/unit"
require 'triangle'

class TestTriangle < MiniTest::Unit::TestCase
  def test_notriangle
    assert_equal(:notriangle, triangle(1,2,3))
    assert_equal(:notriangle, triangle(1,3,2))
    assert_equal(:notriangle, triangle(3,1,2))
  end
  def test_equilateral
    assert_equal(:equilateral, triangle(2,2,2))
    assert_equal(:equilateral, triangle(10,10,10))
  end
  def test_isosceles
    assert_equal(:isosceles, triangle(4,3,4))
    assert_equal(:isosceles, triangle(4,4,3))
    assert_equal(:isosceles, triangle(4,3,4))
  end
  def test_scalene
    assert_equal(:scalene, triangle(5,4,2))
    assert_equal(:scalene, triangle(2,4,3))
  end
end


def testmain(tst, info)
  runner = MiniTest::Unit.new
  test = TestTriangle.new("test_" + tst)
  r = test.run(runner)
  if r != '.'
    raise "Error #{tst} #{info}"
  end
end


