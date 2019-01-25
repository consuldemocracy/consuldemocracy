FactoryBot.define do
  factory :remote_translation do
    association :remote_translatable, factory: :debate
  end
end
