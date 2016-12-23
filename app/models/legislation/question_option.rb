class Legislation::QuestionOption < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :question, class_name: 'Legislation::Question', foreign_key: 'legislation_question_id', inverse_of: :question_options

  validates :question, presence: true
  validates :value, presence: true, uniqueness: { scope: :legislation_question_id }
end
