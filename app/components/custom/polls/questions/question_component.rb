class Polls::Questions::QuestionComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "polls", "questions", "question_component").to_s
