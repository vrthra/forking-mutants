$LOAD_PATH.unshift('./src')
require 'drb'
require 'db'

$db = Db.new(ARGV[0].to_i)
$host = ENV['MHOST'] || 'localhost:9000'
DRb.start_service("druby://#{$host}", $db)
trap("SIGINT") do
  puts ""
  $db.quit
end
$db.wait
