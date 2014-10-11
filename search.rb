require 'resque'
require 'json'
require 'pp'

# Usage:
#   search = Search.new()
#   search.starting = DateTime.parse("2014/10/09 00:00:00 UTC")
#   search.ending = DateTime.parse("2014/10/10 00:00:00 UTC")
#   search.terms = Regexp.new('foo')
#   search.queue = 'QueueName'
#   search.run()
class Search
  attr_accessor :host, :port, :starting, :ending, :terms, :queue, :entries

  def initialize(host='localhost',port=6379)
    self.host = host
    self.port = port
    @offset = 0
    @limit = max
  end

  def run
    # Narrow with binary search
    calculate_starting if starting
    calculate_ending if ending
    raise "More than 1000 entries - please narrow your search" if ((@limit - @offset) > 1000)

    # Fetch entries
    self.entries = Resque.redis.lrange("failed", @offset, @limit).map { |entry| JSON.parse(entry) }

    perform_keywords if terms
    perform_queue if queue

    pp self.entries
  end

  def binary_search(val, low=0, high=(max-1))
    mid = (low + high) / 2
    return mid if high < low # Closest, but no match
    datetime = DateTime.parse(entry(mid)['failed_at'])

    case
    when datetime > val
      binary_search(val, low, mid-1)
    when datetime < val
      binary_search(val, mid+1, high)
    else
      mid
    end
  end

  private

  def entry(index)
    JSON.parse(Resque.redis.lindex("failed", index))
  end

  def max
    Resque.redis.llen "failed"
  end

  def perform_keywords
    self.entries.keep_if do |entry|
      terms =~ "#{entry['payload']['args'].join}#{entry['exception']}#{entry['error']}#{entry['backtrace'].join}"
    end
  end

  def perform_queue
    self.entries.keep_if do |entry|
      queue == entry['payload']['class']
    end
  end

  def calculate_starting
    @offset = binary_search(starting)
  end

  def calculate_ending
    @limit = binary_search(ending)
  end
end
