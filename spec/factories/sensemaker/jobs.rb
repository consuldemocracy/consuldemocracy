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
    published { false }

    trait :unpublished do
      script { "runner.ts" }
      published { false }
    end

    trait :published do
      script { "runner.ts" }
      published { true }
    end

    trait :report do
      script { "sensemaking-report-ui" }
    end

    trait :publishable do
      script { "sensemaking-report-ui" }
      finished_at { Time.current }
      error { nil }
      published { false }
    end
  end
end
