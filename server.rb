require 'dotenv' # Manage environment variables
require 'redis'
require 'sinatra'

# NOTE:
#   by default, when Sinatra is run in development mode as in this case,
#   for security reasons only connections from the localhost of the
#   guest machine are allowed
# The next line allows connections from the host machine
set :bind, '0.0.0.0'

# use the default Sinatra port to listen on the guest machine
set :port, 4567

# Load environment variables from the ".env" file
Dotenv.load('.env')

# an exception will be thrown if the required keys are not defined in the ".env" file
Dotenv.require_keys('REDIS_URL')

puts "DEBUG: ENV['REDIS_URL'] = #{ENV['REDIS_URL']}"
redis = Redis.new(url: ENV['REDIS_URL'])

REDIS_KEY_REQUEST_NUMBER = "REQUEST_NUMBER"
REDIS_KEY_LIST_OF_REQUEST_TIMESTAMPS = "LIST_OF_REQUEST_TIMESTAMPS"


get '/' do
  return 'Hello world root route!' # the return keyword can be omitted in Ruby
end

get '/hello_redis' do
  # see https://redis.io/commands/incr
  # If the key does not exist, it is set to 0 before performing the increment
  redis.incr(REDIS_KEY_REQUEST_NUMBER)

  # see https://redis.io/commands/lpush
  # append a timestamp to the front of the list
  redis.lpush(REDIS_KEY_LIST_OF_REQUEST_TIMESTAMPS, Time.new())

  # see https://redis.io/commands/get
  request_number = redis.get(REDIS_KEY_REQUEST_NUMBER)

  # see https://redis.io/commands/lrange
  # retrieve all entries from the list, starting at index 0 until the last element (i.e., -1)
  list_of_request_timestamps = redis.lrange(REDIS_KEY_LIST_OF_REQUEST_TIMESTAMPS, 0, -1)

  # for debugging only: see output of these commands in the console
  puts "request_number             = #{request_number}"
  puts "list_of_request_timestamps = #{list_of_request_timestamps}"

  # see https://docs.ruby-lang.org/en/2.3.0/ERB.html for more details about ERB (Embedded RuBy)
  # The following command will:
  # - pass the variables request_number and list_of_request_timestamps to the "views/hello_redis.erb"
  # - process any ruby code and
  # - return the resulting HTML to the browser
  erb :hello_redis, locals: { request_number: request_number, list_of_request_timestamps: list_of_request_timestamps }
end
