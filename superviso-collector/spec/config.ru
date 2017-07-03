require './app'

use Rack::PostBodyContentTypeParser
use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Sinatra::Application
