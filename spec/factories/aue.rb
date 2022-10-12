FactoryBot.define do
  factory :aue_goal, class: "AUE::Goal" do
    sequence(:code) { |n| n }
  end
end
