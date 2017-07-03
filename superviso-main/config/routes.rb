Superviso::Application.routes.draw do
  devise_for :users, :only => [:sessions, :registration, :password, :passwords, :confirmation]

  mount Dashing::Engine, at: Dashing.config.engine_path

  resources :dashboards do
    resources :widgets
    get '/script/:uid', to: :script, on: :collection, as: :script
  end

  resource :user do
    get :profile, to: :show
  end

  post "pusher/auth"

  resources :announcements do
    member do
      get :hide
    end
  end

  root :to => "dashboards#index"       
end
