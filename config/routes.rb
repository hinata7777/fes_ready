Rails.application.routes.draw do
  devise_for :users
  root "home#top"
  
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    root "home#top"
  end
end
