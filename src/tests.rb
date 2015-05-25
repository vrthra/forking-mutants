class Tester
  def initialize
    @tests = [
      [:equilateral, [2, 2, 2]],
      [:equilateral, [10, 10, 10]],
      [:isosceles, [3, 4, 4]],
      [:isosceles, [4, 3, 4]],
      [:isosceles, [4, 4, 3]],
      [:isosceles, [10, 10, 2]],
      [:scalene, [3, 4, 5]],
      [:scalene, [10, 11, 12]],
      [:scalene, [5, 4, 2]],
      [:notriangle, [1,2,10]],
      [:notriangle, [1,10,2]],
      [:notriangle, [10,1,2]]
    ]
  end
  def test(arg, xinfo)
    t = @tests[arg]
    kind = t[0]
    args = t[1]
    kind == triangle(args[0], args[1], args[2]) or raise "#{kind} #{arg} #{xinfo}"
  end
end

def testmain(arg, info)
  Tester.new().test(arg.to_i, info)
end
