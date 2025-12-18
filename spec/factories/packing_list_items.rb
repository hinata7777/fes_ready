FactoryBot.define do
  factory :packing_list_item do
    association :packing_list, strategy: :create
    association :item, strategy: :create
    position { 0 }
    checked { false }
    note { nil }
  end
end
