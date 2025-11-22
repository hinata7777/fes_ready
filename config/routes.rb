Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords"
  }

  root "home#top"
  get "/terms", to: "home#terms", as: :terms
  get "/privacy", to: "home#privacy", as: :privacy

  get "up" => "rails/health#show", as: :rails_health_check
  get "/service-worker.js", to: "rails/pwa#service_worker", defaults: { format: :js }, as: :pwa_service_worker
  get "/manifest.webmanifest", to: "rails/pwa#manifest", defaults: { format: :json }, as: :pwa_manifest

  resources :artists, only: [ :index, :show ] do
    resources :festivals, only: [ :index ], module: :artists
  end

  resources :timetables, only: [ :index, :show ]
  resources :my_timetables, only: [ :index ]
  resource :mypage, only: [ :show ]
  namespace :mypage do
    resources :favorite_festivals, only: [ :index ], path: "festivals"
  end

  resources :festivals, only: [ :index, :show ] do
    resources :artists, only: [ :index ], module: :festivals
    resource :my_timetable, only: [ :show, :edit, :update, :destroy ], controller: :my_timetables
    resource :favorite, only: [ :create, :destroy ], module: :festivals
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
