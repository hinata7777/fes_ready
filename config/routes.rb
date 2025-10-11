Rails.application.routes.draw do
  devise_for :users
  root "home#top"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :artists, only: [ :index, :show ]

  namespace :admin do
    root "home#top"
    resources :users, only: :index
    resources :artists
    get "spotify/search", to: "spotify#search"
  end
end
