FactoryBot.define do
  factory :sensemaker_job, class: 'Sensemaker::Job' do
    user
    script { "categorization_runner.ts" }
    started_at { Time.current }
    finished_at { nil }
    error { nil }
    commentable_type { "Debate" }
    commentable_id { create(:debate).id }
    additional_context { "Test context" }
  end
end
