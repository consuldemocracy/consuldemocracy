class Legislation::QuestionOption < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :value, touch: true
  globalize_accessors

  belongs_to :question, class_name: 'Legislation::Question', foreign_key: 'legislation_question_id', inverse_of: :question_options
  has_many :answers, class_name: 'Legislation::Answer', foreign_key: 'legislation_question_id', dependent: :destroy, inverse_of: :question

  validates :question, presence: true
  validates :value, presence: true, uniqueness: { scope: :legislation_question_id }
end
