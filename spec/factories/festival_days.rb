FactoryBot.define do
  factory :festival_day do
    association :festival
    date { festival.start_date }
  end
end
