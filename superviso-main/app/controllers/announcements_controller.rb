class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  def hide
    a = Announcement.find(params[:id])
    current_user.hide_announcement(a)
    redirect_to :back
  end
end
