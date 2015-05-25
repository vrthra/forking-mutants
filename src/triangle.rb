def triangle(a, b, c)
  if ((a + b) <= c) | ((a + c) <= b) | ((b + c) <= a)
    return :notriangle
  elsif ((a == b) & (a == c) & (b == c))
    return :equilateral
  elsif ((a == b) | (a == c) | (b == c))
    return :isosceles
  else
    return :scalene
  end
end

