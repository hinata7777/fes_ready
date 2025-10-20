Rails.application.routes.draw do
  devise_for :users
  root "home#top"
  get "up" => "rails/health#show", as: :rails_health_check
  resources :artists, only: [:index, :show] 
  resources :festivals, only: [:index, :show] do
    resources :artists, only: [:index], controller: :artists
  end

  namespace :admin do
    root "home#top"
    get "spotify/search", to: "spotify#search"
    resources :users, only: :index
    resources :artists
    resources :stage_performances
    resources :festivals do
      member do
        get  :setup
        patch :apply
      end
    end
  end
end
