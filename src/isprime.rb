def isprime?(number)
	if (number == 0) | (number == 1)
		return false
	end

	i = 2
	limit = number / i
	while i < limit
		if number % i == 0
			return false
		end
		i = i + 1
		limit = number / i
	end
	return true
rescue
  return false
end

