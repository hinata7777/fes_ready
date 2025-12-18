FactoryBot.define do
  factory :user_timetable_entry do
    association :user, strategy: :create
    association :stage_performance, strategy: :create
  end
end
