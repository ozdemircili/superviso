require 'sinatra'
require 'sinatra/activerecord'
require "sinatra/json"
require 'rack/contrib'
require 'active_record'
require 'uri'
require "em-http"
require 'pusher'
require 'thin'
require 'connection_pool'
require 'redis'

# Handle database connection
database_url = ENV['DATABASE_URL'] 
if settings.development? or settings.test?
  require 'dotenv'
  Dotenv.load
  database_url = ENV['DATABASE_URL_DEVELOPMENT'] if settings.development?
  database_url = ENV['DATABASE_URL_TEST'] if settings.test?
end

db = URI.parse(database_url)
if settings.development? or settings.test?
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
else
  ActiveRecord::Base.establish_connection(
    :adapter  => 'postgresql',
    :host     => db.host,
    :port     => db.port,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8',
    :pool => 10
  )
end

configure do 
  Pusher.url = ENV["PUSHER_URL"]
  Pusher.timeout = 30
  RedisPool = ConnectionPool.new(size: 20, timeout: 30){ Redis.connect } 
end

# Models
class User < ActiveRecord::Base
  has_many :dashboards
  has_many :widgets, through: :dashboards

  def self.authenticated?(params)
    auth_token = (params["auth_token"] || "").to_s
    user = User.where(auth_token: auth_token).limit(1).try(:first)
    return (not user.nil?)
  end
  
  def self.authorized?(params)
    auth_token = (params["auth_token"] || "").to_s
    user = User.where(auth_token: auth_token).limit(1).try(:first)
    if params[:widgets]
      params[:widgets].each do |widget|
        return false if user.widgets.where(secret_token: widget["widget"]).limit(1).try(:first).nil?
      end
      return true
    else
      widget = user.widgets.where(secret_token: params[:widget]).limit(1).try(:first)
      return (not widget.nil?)
    end
  end
end
class Dashboard < ActiveRecord::Base
  belongs_to :user
  has_many :widgets

  def pusher_channel
    "private-dashboard-#{self.id}"
  end
end
class Widget < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :dashboard
end

helpers do 
  def authenticate!
    halt 401 unless User.authenticated?(params)
  end

  def authorize!
    halt 401 unless User.authorized?(params)
  end

end

before '/' do
  content_type 'application/json'
  logger.info "Authenticate"
  authenticate!
  logger.info "Authorize"
  authorize!
end

#Endpoints
post '/' do
  #FIXME: we should send only the params valid for the current widget
  #FIXME: reply with 404 if widget not found
  logger.info "Dashbaord Query"
  if params[:widgets]
    widgets_params = params[:widgets]
  else
    widgets_params = [params]
  end
  
  widgets_params.each do |widget_params|
    dashboard = Widget.where(secret_token: widget_params["widget"]).first.dashboard
    channel_name = dashboard.pusher_channel
    parameters =  widget_params.merge({id: widget_params["widget"], updatedAt: Time.now.utc.to_i})
    logger.info "Dashbaord Query done #{channel_name} #{parameters}"
    Pusher.trigger(channel_name, 'update',  parameters)
    RedisPool.with do |conn|
      conn.set("w:#{widget_params["widget"]}:last", parameters.to_json)
    end
    logger.info "Push"
  end
  json :success => "ok"
end
