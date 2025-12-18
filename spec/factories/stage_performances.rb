FactoryBot.define do
  factory :stage_performance do
    association :festival_day, strategy: :create
    association :artist, strategy: :create
    status { :draft }

    trait :scheduled do
      association :stage, strategy: :create
      status { :scheduled }
      starts_at { festival_day.date.to_time.change(hour: 12) }
      ends_at   { festival_day.date.to_time.change(hour: 13) }
    end
  end
end
