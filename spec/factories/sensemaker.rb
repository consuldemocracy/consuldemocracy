FactoryBot.define do
  factory :sensemaker_job do
    user
    script { "categorization_runner.ts" }
    started_at { Time.current }
    finished_at { nil }
    error { nil }
    commentable_type { "Debate" }
    commentable_id { create(:debate).id }
    additional_context { "Test context" }
  end

  factory :sensemaker_info do
    kind { "categorization" }
    generated_at { Time.current }
    script { "categorization_runner.ts" }
    commentable_type { "Debate" }
    commentable_id { create(:debate).id }
  end
end
