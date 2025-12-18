FactoryBot.define do
  factory :item do
    association :user, strategy: :create
    sequence(:name) { |n| "Item #{n}" }
    template { false }
  end

  factory :template_item, parent: :item do
    user { nil }
    template { true }
  end
end
