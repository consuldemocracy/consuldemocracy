FactoryBot.define do
  factory :sensemaker_job, class: "Sensemaker::Job" do
    user
    script { "categorization_runner.ts" }
    started_at { Time.current }
    finished_at { nil }
    error { nil }
    analysable_type { "Debate" }
    analysable_id { create(:debate).id }
    additional_context { "Test context" }
    published { true }

    trait :unpublished do
      published { false }
    end

    trait :published do
      published { true }
    end
  end
end
