FactoryBot.define do
  factory :festival do
    sequence(:name) { |n| "Festival #{n}" }
    sequence(:slug) { |n| "festival-#{n}" }
    start_date { Date.current + 30.days }
    end_date { start_date + 1.day }
    timezone { "Asia/Tokyo" }
    venue_name { "会場" }
    latitude { 35.0 }
    longitude { 139.0 }
  end
end
