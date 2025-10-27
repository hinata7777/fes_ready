Rails.application.routes.draw do
  devise_for :users

  root "home#top"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :artists, only: [:index, :show] do
    resources :festivals, only: [:index], controller: :festivals
  end

  resources :timetables, only: [:index]

  resources :festivals, only: [:index, :show] do
    resources :artists, only: [:index], controller: :artists
    member do
      get :timetable
      # マイタイムテーブル（作成→保存→表示）
      get  "my_timetable/build", to: "my_timetables#build",  as: :build_my_timetable
      post "my_timetable",       to: "my_timetables#create", as: :my_timetable
      get  "my_timetable",       to: "my_timetables#show"
    end
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
