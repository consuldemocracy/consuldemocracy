FactoryBot.define do
  factory :sensemaker_info, class: "Sensemaker::Info" do
    kind { "categorization" }
    commentable_type { "Debate" }
    commentable_id { create(:debate).id }
    script { "categorization_runner.ts" }
    generated_at { Time.current }
  end
end
