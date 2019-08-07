FactoryBot.define do
  factory :votation_type do
    factory :votation_type_unique do
      enum_type { "unique" }
      open_answer { false }
      prioritized { false }
    end

    factory :votation_type_multiple do
      enum_type { "multiple" }
      open_answer { false }
      prioritized { false }
      max_votes { 5 }
    end

    factory :votation_type_prioritized do
      enum_type { "prioritized" }
      open_answer { false }
      prioritized { true }
      max_votes { 5 }
      prioritization_type { "borda" }
    end

    factory :votation_type_positive_open do
      enum_type { "positive_open" }
      open_answer { true }
      prioritized { false }
      max_votes { 5 }
    end

    factory :votation_type_positive_negative_open do
      enum_type { "positive_negative_open" }
      open_answer { true }
      prioritized { false }
      max_votes { 5 }
      prioritization_type { "borda" }
    end

    factory :votation_type_answer_couples_open do
      enum_type { "answer_couples_open" }
      open_answer { true }
      prioritized { false }
      max_votes { 5 }
    end

    factory :votation_type_answer_couples_closed do
      enum_type { "answer_couples_open" }
      open_answer { false }
      prioritized { false }
      max_votes { 5 }
    end

    factory :votation_type_answer_set_open do
      enum_type { "answer_set_open" }
      open_answer { true }
      prioritized { false }
      max_votes { 3 }
      max_groups_answers { 5 }
    end

    factory :votation_type_answer_set_closed do
      enum_type { "answer_set_open" }
      open_answer { false }
      prioritized { false }
      max_votes { 3 }
      max_groups_answers { 5 }
    end

    trait :open do
      open_answer { true }
    end
    trait :prioritized do
      prioritized { true }
    end

  end
end
