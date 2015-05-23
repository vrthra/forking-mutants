run:
	ruby src/metamut.rb

clean:
	@rm -f parent*.log
	@rm -f log/*.dead
	@rm -f log/*.alive
