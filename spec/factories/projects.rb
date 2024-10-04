FactoryBot.define do
  factory :project do
    sequence(:title)	{ |n| "Project #{n} title" }
    sequence(:slug)		{ |n| "#{n}" }
    content				{ "Project content" }
    teaser				{ "Project teaser" }
    state				{ "draft" }

    trait :with_phase do
      after(:create) { |project| create(:project_phase, imageable: budget) }
    end
  end

  factory :project_phase, class: "Project::Phase" do
    sequence(:title_short)  { |n| "Phase #{n} short_title" }
    title			    { "Phase title" }
    subtitle			{ "Phase sub-title" }
    content				{ "Phase content" }
    project factory: :project
  end
end
