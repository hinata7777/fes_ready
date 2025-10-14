Rails.application.routes.draw do
  devise_for :users
  root "home#top"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :artists, only: [ :index, :show ]

  namespace :admin do
    root "home#top"
    get "spotify/search", to: "spotify#search"
    resources :users, only: :index
    resources :artists
    resources :festivals do
      member do
        get  :setup   # 日程・ステージをまとめて編集する画面
        patch :apply  # ネスト更新のsubmit先
      end
    end
  end
end
