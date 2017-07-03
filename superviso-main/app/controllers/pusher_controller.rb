class PusherController < ApplicationController
  protect_from_forgery :except => :auth
  respond_to :json
  
  before_action :authenticate_subscriber
  before_action :load_resource
  before_action :authorize_subscriber

  def auth
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
    render json: response
  end

  private

  def authenticate_subscriber
    head 403 unless user_signed_in?
  end

  def load_resource
    # So far we deal only with dashboard channels
    id = params[:channel_name].split("-")[2]
    @dashboard = Dashboard.find(id)
  end

  def authorize_subscriber
    head 403 unless @dashboard.user == current_user
  end
end
