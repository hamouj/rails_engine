FactoryBot.define do
  factory :invoice do
    status { "shipped" }
    association :merchant, :customer
    
    trait :packaged do
      status { "packaged" }
    end

    trait :returned do
      status { "returned" }
    end

    factory :packaged_invoice, traits: [:packaged]
    factory :returned_invoice, traits: [:returned]
  end
end