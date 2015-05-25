server:
	ruby src/controller.rb

client:
	ruby src/metamut.rb ./src/triangle.rb ./src/tests.rb notriangle

scalene:
	ruby src/metamut.rb ./src/triangle.rb ./src/tests.rb scalene

equilateral:
	ruby src/metamut.rb ./src/triangle.rb ./src/tests.rb equilateral

isosceles:
	ruby src/metamut.rb ./src/triangle.rb ./src/tests.rb isosceles

clean:
	@rm -f parent*.log
	@rm -f log/*.dead
	@rm -f log/*.alive
