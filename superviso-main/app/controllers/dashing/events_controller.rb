module Dashing
  class EventsController < ApplicationController
    include ActionController::Live

    respond_to :html
    def index
      head :forbidden
      response.headers['Content-Type']      = 'text/event-stream'
      response.headers['X-Accel-Buffering'] = 'no'
      
      @redis = Dashing.redis
      @redis.psubscribe("#{Dashing.config.redis_namespace}.*") do |on|
        on.pmessage do |pattern, event, data|
          logger.info "[Dashing][#{Time.now.utc.to_s}] Stream Data [#{data}]"
          response.stream.write("data: #{data}\n\n")
        end
      end
    rescue IOError => ex
      puts ex
      logger.info "[Dashing][#{Time.now.utc.to_s}] Stream closed"
    ensure
      @redis.quit
      response.stream.close
    end
=begin
    def index 
      response.headers['Content-Type']      = 'text/event-stream'
      response.headers['X-Accel-Buffering'] = 'no'
      @redis = Dashing.redis
      begin
        ticker = Thread.new { loop { response.stream.write("data: {}\n\n"); sleep 2 } }
        sender = Thread.new do
          @redis.psubscribe("#{Dashing.config.redis_namespace}.*") do |on|
            on.pmessage do |pattern, event, data|
              puts data
              response.stream.write("data: #{data}\n\n")
            end
          end
        end
        ticker.join
        sender.join
      rescue IOError
        logger.info "[Dashing][#{Time.now.utc.to_s}] Stream closed"
      ensure
        @redis.quit
        response.stream.close
        Thread.kill(ticker) if ticker
        Thread.kill(sender) if sender
      end
    end
=end
  end
end
