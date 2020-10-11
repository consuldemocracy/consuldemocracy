class Legislation::Answer < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :question, foreign_key: "legislation_question_id", inverse_of: :answers, counter_cache: true
  belongs_to :question_option, foreign_key: "legislation_question_option_id",
                               inverse_of: :answers, counter_cache: true
  belongs_to :user, inverse_of: :legislation_answers

  validates :question, presence: true, uniqueness: { scope: :user_id }
  validates :question_option, presence: true
  validates :user, presence: true
end
