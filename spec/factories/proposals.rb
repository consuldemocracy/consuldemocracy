FactoryBot.define do
  factory :proposal do
    sequence(:title)     { |n| "Proposal #{n} title" }
    sequence(:summary)   { |n| "In summary, what we want is... #{n}" }
    description          "Proposal description"
    question             "Proposal question"
    external_url         "http://external_documention.es"
    video_url            "https://youtu.be/nhuNb0XtRhQ"
    responsible_name     "John Snow"
    terms_of_service     "1"
    skip_map             "1"
    association :author, factory: :user

    trait :hidden do
      hidden_at { Time.current }
    end

    trait :with_ignored_flag do
      ignored_flag_at { Time.current }
    end

    trait :with_confirmed_hide do
      confirmed_hide_at { Time.current }
    end

    trait :flagged do
      after :create do |proposal|
        Flag.flag(create(:user), proposal)
      end
    end

    trait :archived do
      created_at { 25.months.ago }
    end

    trait :with_hot_score do
      before(:save) { |d| d.calculate_hot_score }
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end

    trait :conflictive do
      after :create do |debate|
        Flag.flag(create(:user), debate)
        4.times { create(:vote, votable: debate) }
      end
    end

    trait :successful do
      cached_votes_up { Proposal.votes_needed_for_success + 100 }
    end
  end

  factory :proposal_notification do
    sequence(:title) { |n| "Thank you for supporting my proposal #{n}" }
    sequence(:body) { |n| "Please let others know so we can make it happen #{n}" }
    proposal
    association :author, factory: :user

    trait :moderated do
      moderated true
    end

    trait :ignored do
      ignored_at { Date.current }
    end

    trait :hidden do
      hidden_at { Date.current }
    end

    trait :with_confirmed_hide do
      confirmed_hide_at { Time.current }
    end
  end

  factory :signature_sheet do
    association :signable, factory: :proposal
    association :author, factory: :user
    document_numbers "123A, 456B, 789C"
  end

  factory :signature do
    signature_sheet
    sequence(:document_number) { |n| "#{n}A" }
  end

  factory :activity do
    user
    action "hide"
    association :actionable, factory: :proposal
  end
end
