Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords"
  }

  root "home#top"
  get "/terms", to: "home#terms", as: :terms
  get "/privacy", to: "home#privacy", as: :privacy
  get "/prep", to: "prep#top", as: :prep_top
  namespace :prep, path: "prep" do
    resources :artists, only: [ :index ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "/service-worker.js", to: "rails/pwa#service_worker", defaults: { format: :js }, as: :pwa_service_worker
  get "/manifest.webmanifest", to: "rails/pwa#manifest", defaults: { format: :json }, as: :pwa_manifest

  resources :artists, only: [ :index, :show ] do
    get :prep, on: :member
    resources :festivals, only: [ :index ], module: :artists
    resource :favorite, only: [ :create, :destroy ], module: :artists
  end

  resources :setlists, only: [ :show ]
  resources :timetables, only: [ :index, :show ]
  resources :my_timetables, only: [ :index ]
  namespace :mypage, path: "mypage" do
    get "/", to: "dashboard#show", as: :dashboard
    resources :favorite_festivals, only: [ :index ], path: "festivals"
    resources :favorite_artists, only: [ :index ], path: "artists"
  end

  resources :festivals, only: [ :index, :show ] do
    resources :artists, only: [ :index ], module: :festivals
    resource :my_timetable, only: [ :show, :edit, :update, :destroy ], controller: :my_timetables
    resource :favorite, only: [ :create, :destroy ], module: :festivals
  end

  resources :packing_lists do
    resources :packing_list_items, only: [ :create, :update, :destroy ] do
      member do
        patch :toggle
      end
    end
    member do
      post :duplicate_from_template
    end
  end

  namespace :admin do
    root "home#top"
    get "spotify/search", to: "spotify#search"
    get "spotify/search_tracks", to: "spotify#search_tracks"
    resources :users, only: :index
    resources :artists
    resources :festival_tags
    resources :songs do
      collection do
        get :bulk_new
        post :bulk_create
      end
    end
    resources :setlists
    resources :stage_performances do
      # 一括追加用
      collection do
        get :bulk_new
        post :bulk_create
      end
    end
    resources :festivals do
      member do
        get  :setup
        patch :apply
      end
    end
    resources :items, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :packing_lists, only: [ :index, :new, :create, :edit, :update, :destroy ]
  end
end
