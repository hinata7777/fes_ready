FactoryBot.define do
  factory :user_festival_favorite do
    association :user, strategy: :create
    association :festival, strategy: :create
  end
end
