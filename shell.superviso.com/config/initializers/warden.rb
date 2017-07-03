Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find_by_id(id)
end

require 'auth_cookie_strategy'

Rails.application.config.middleware.insert_after ActionDispatch::Flash, Warden::Manager do |manager|
end
