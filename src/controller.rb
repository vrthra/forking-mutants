$LOAD_PATH.unshift('./src')
require 'drb'
require 'db'

num_children = ARGV[0].to_i
db = Db.new(num_children)
host = ENV['MHOST'] || 'localhost:9000'
DRb.start_service("druby://#{host}", db)
trap("SIGINT") do
  puts ""
  db.quit
end
db.wait
