FactoryBot.define do
  factory :setlist_song do
    association :setlist, strategy: :create
    association :song, strategy: :create
    position { 1 }
  end
end
