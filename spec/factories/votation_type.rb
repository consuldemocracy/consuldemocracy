FactoryBot.define do
  factory :votation_type do
    factory :votation_type_unique do
      enum_type { "unique" }
      prioritized { false }
    end

    factory :votation_type_multiple do
      enum_type { "multiple" }
      prioritized { false }
      max_votes { 3 }
    end

    factory :votation_type_prioritized do
      enum_type { "prioritized" }
      prioritized { true }
      max_votes { 3 }
    end

    trait :prioritized do
      prioritized { true }
    end
  end
end
