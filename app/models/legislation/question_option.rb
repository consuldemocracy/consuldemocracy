class Legislation::QuestionOption < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :question, class_name: 'Legislation::Question', foreign_key: 'legislation_question_id', inverse_of: :question_options
  has_many :answers, class_name: 'Legislation::Answer', foreign_key: 'legislation_question_id', dependent: :destroy, inverse_of: :question

  validates :question, presence: true
  validates :value, presence: true, uniqueness: { scope: :legislation_question_id }
end

# == Schema Information
#
# Table name: legislation_question_options
#
#  id                      :integer          not null, primary key
#  legislation_question_id :integer
#  value                   :string
#  answers_count           :integer          default(0)
#  hidden_at               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
