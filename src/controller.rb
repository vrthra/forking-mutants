require 'drb'
require 'thread'
 

class Db
  def initialize(tsts)
    @mutants = {}
    @mutex = Mutex.new
    @hai = tsts
    @bye = 0
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
      if @mutants[m].nil?
        STDERR.puts "killed #{m}"
      else
        puts "\t#{m} + #{@mutants[m]}"
      end
      @mutants[m] = 1
    end
  end
  def score
    "#{@mutants.values.inject(0,:+)}/#{@mutants.values.length}"
  end
  def bye
    @bye += 1
  end
  def wait
    if @hai == 0
      DRb.thread.join
    else
      while @bye < @hai
        sleep 1
      end
      quit
    end
  end

  def quit
    DRb.stop_service
    puts "Mutation Score = #{score}"
    exit(0)
  end
end

$db = Db.new(ARGV[0].to_i)
DRb.start_service('druby://localhost:9000', $db)
trap("SIGINT") do
  puts ""
  $db.quit
end
$db.wait
