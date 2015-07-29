primeserver:
	@echo Mutants = $$(ruby ./src/mutate.rb -count ./src/isprime.rb)
	ruby src/controller.rb

primeclient:
	ruby src/metamut.rb ./src/isprime.rb ./src/test_isprime.rb noprime
	ruby src/metamut.rb ./src/isprime.rb ./src/test_isprime.rb prime

triangleserver:
	@echo Mutants = $$(ruby ./src/mutate.rb -count ./src/triangle.rb)
	ruby src/controller.rb

triangleclient:
	ruby src/metamut.rb ./src/triangle.rb ./src/test_triangle.rb notriangle

scalene:
	ruby src/metamut.rb ./src/triangle.rb ./src/test_triangle.rb scalene

equilateral:
	ruby src/metamut.rb ./src/triangle.rb ./src/test_triangle.rb equilateral

isosceles:
	ruby src/metamut.rb ./src/triangle.rb ./src/test_triangle.rb isosceles

trianglesrc:
	ruby ./src/mutate.rb -src ./src/triangle.rb

clean:
	@rm -f parent*.log
	@rm -f log/*.dead
	@rm -f log/*.alive
