class Legislation::Question < ActiveRecord::Base
  belongs_to :process, class_name: 'Legislation::Process', foreign_key: 'legislation_process_id'

  has_many :question_options, class_name: 'Legislation::QuestionOption', foreign_key: 'legislation_question_id', dependent: :destroy, inverse_of: :question
  # has_many :answers
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :question_options, :reject_if => proc { |attributes| attributes[:value].blank? }, allow_destroy: true

  validates :process, presence: true
  validates :title, presence: true

  def next_question_id
    @next_question_id ||= process.questions.where("id > ?", id).limit(1).pluck(:id).first
  end
end
