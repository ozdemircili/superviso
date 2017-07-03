class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  
  
  def after_sign_in_path_for(resource)
   dashboards_path
  end

  def set_locale
    return unless current_user
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    if current_user.locale.nil? or current_user.locale.empty?
      I18n.locale = extract_locale_from_accept_language_header
    else
      I18n.locale = current_user.locale
    end

    logger.debug "* Locale set to '#{I18n.locale}'"
  end
  

  private
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

end
