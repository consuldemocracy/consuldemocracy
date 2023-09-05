FactoryBot.define do
  factory :map do
    association :budget, factory: :budget
  end
end
