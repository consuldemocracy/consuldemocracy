class Legislation::QuestionOption < ActiveRecord::Base
  belongs_to :question, class_name: 'Legislation::Question', foreign_key: 'legislation_question_id', inverse_of: :question_options

  # has_many :answers

  validates :question, presence: true
  validates :value, presence: true, uniqueness: { scope: :legislation_question_id }
end
