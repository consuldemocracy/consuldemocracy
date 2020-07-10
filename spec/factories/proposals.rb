FactoryBot.define do
  factory :proposal do
    sequence(:title)     { |n| "Proposal #{n} title" }
    sequence(:summary)   { |n| "In summary, what we want is... #{n}" }
    description          { "Proposal description" }
    video_url            { "https://youtu.be/nhuNb0XtRhQ" }
    responsible_name     { "John Snow" }
    terms_of_service     { "1" }
    published_at         { Time.current }

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

    trait :selected do
      selected { true }
    end

    trait :with_hot_score do
      before(:save, &:calculate_hot_score)
    end

    trait :with_confidence_score do
      before(:save, &:calculate_confidence_score)
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

    trait :draft do
      published_at { nil }
    end

    trait :retired do
      retired_at { Time.current }
      retired_reason { "unfeasible" }
      retired_explanation { "Retired explanation" }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :with_milestone_tags do
      after(:create) { |proposal| proposal.milestone_tags << create(:tag, :milestone) }
    end

    trait :with_image do
      after(:create) { |proposal| create(:image, imageable: proposal) }
    end

    transient do
      voters { [] }
      followers { [] }
    end

    after(:create) do |proposal, evaluator|
      evaluator.voters.each { |voter| create(:vote, votable: proposal, voter: voter) }
      evaluator.followers.each { |follower| create(:follow, followable: proposal, user: follower) }
    end

    factory :retired_proposal, traits: [:retired]
  end

  factory :proposal_notification do
    sequence(:title) { |n| "Thank you for supporting my proposal #{n}" }
    sequence(:body) { |n| "Please let others know so we can make it happen #{n}" }
    proposal
    association :author, factory: :user

    trait :moderated do
      moderated { true }
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
    required_fields_to_verify { "123A, 456B, 789C" }
  end

  factory :signature do
    signature_sheet
    sequence(:document_number) { |n| "#{n}A" }
  end

  factory :activity do
    user
    action { "hide" }
    association :actionable, factory: :proposal
  end

  factory :dashboard_action, class: "Dashboard::Action" do
    title { Faker::Lorem.sentence[0..79].strip }
    description { Faker::Lorem.sentence }
    link { nil }
    request_to_administrators { true }
    day_offset { 0 }
    required_supports { 0 }
    order { 0 }
    active { true }
    hidden_at { nil }
    action_type { "proposed_action" }

    trait :admin_request do
      request_to_administrators { true }
    end

    trait :external_link do
      link { Faker::Internet.url }
    end

    trait :inactive do
      active { false }
    end

    trait :active do
      active { true }
    end

    trait :deleted do
      hidden_at { Time.current }
    end

    trait :proposed_action do
      action_type { "proposed_action" }
    end

    trait :resource do
      action_type { "resource" }
    end
  end

  factory :dashboard_executed_action, class: "Dashboard::ExecutedAction" do
    proposal
    action { |s| s.association(:dashboard_action) }
    executed_at { Time.current }
  end

  factory :dashboard_administrator_task, class: "Dashboard::AdministratorTask" do
    source { |s| s.association(:dashboard_executed_action) }
    user
    executed_at { Time.current }

    trait :pending do
      user { nil }
      executed_at { nil }
    end

    trait :done do
      user
      executed_at { Time.current }
    end
  end

  factory :link do
    linkable { |s| s.association(:action) }
    label { Faker::Lorem.sentence }
    url { Faker::Internet.url }
  end
end
