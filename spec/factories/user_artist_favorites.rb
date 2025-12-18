FactoryBot.define do
  factory :user_artist_favorite do
    association :user, strategy: :create
    association :artist, strategy: :create
  end
end
