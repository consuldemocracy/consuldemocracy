class Legislation::QuestionOption < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :value, touch: true
  include Globalizable

  belongs_to :question, foreign_key: "legislation_question_id", inverse_of: :question_options
  has_many :answers, foreign_key: "legislation_question_id", dependent: :destroy, inverse_of: :question

  validates :question, presence: true
  validates_translation :value, presence: true
end
