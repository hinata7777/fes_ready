FactoryBot.define do
  factory :packing_list do
    association :user, strategy: :create
    sequence(:title) { |n| "持ち物リスト #{n}" }
    template { false }
    uuid { SecureRandom.uuid }

    trait :with_festival_day do
      association :festival_day
    end
  end

  factory :template_packing_list, parent: :packing_list do
    user { nil }
    template { true }
  end
end
