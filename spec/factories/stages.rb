FactoryBot.define do
  factory :stage do
    association :festival, strategy: :create
    sequence(:name) { |n| "Stage #{n}" }
    color_key { "slate" }
  end
end
