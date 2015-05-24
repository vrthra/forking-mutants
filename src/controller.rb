require 'drb'
require 'thread'
 

class Db
  def initialize
    @mutants = {}
    @mutex = Mutex.new
  end
  def has?(m)
    not(@mutants[m].nil?)
  end
  def killed?(m)
    not(@mutants[m].nil?) and @mutants[m] == 1
  end
  def start(m)
    @mutex.synchronize do
      @mutants[m] = 0
    end
  end
  def killed(m)
    @mutex.synchronize do
      @mutants[m] = 1
    end
  end
  def score
    "#{@mutants.values.inject(0,:+)}/#{@mutants.values.length}"
  end
end

$db = Db.new
 
# Start the service
DRb.start_service('druby://localhost:9000', $db)
 
# Make the main thread wait for the DRb thread,
# otherwise the script execution would already end here.
trap("SIGINT") do
  DRb.stop_service
  puts ""
  puts "Mutation Score = #{$db.score}"
end
DRb.thread.join
