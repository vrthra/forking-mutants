require 'isprime'
require 'prime'
require "minitest/unit"
MaxNum = 10000000
class TestPrime < MiniTest::Unit::TestCase
  def setup
    @p = 0
    @p1 = 0
    while true
      @p = (Prime.first MaxNum).last
      @p1 = (Prime.first MaxNum + 1).last
      if (@p1 - @p) > 1
        break
      end
    end

  end
  def test_noprime
    #assert_equal(false, isprime?(0))
    #assert_equal(false, isprime?(1))
    assert_equal(false, isprime?(@p1 - 1))
  end
  def test_prime
    #assert_equal(true, isprime?(2))
    assert_equal(true, isprime?(@p))
  end

end


def testmain(tst, info)
  runner = MiniTest::Unit.new
  test = TestPrime.new("test_" + tst)
  r = test.run(runner)
  if r != '.'
    raise "Error #{tst} #{info}"
  end
end

#testmain 'noprime', 'x'
