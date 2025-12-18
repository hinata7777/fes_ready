FactoryBot.define do
  factory :song do
    association :artist, strategy: :create
    sequence(:name) { |n| "Song #{n}" }
    spotify_id { "0OdUWJ0sBjDrqHygGUXeCF" }
  end
end
