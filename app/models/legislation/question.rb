class Legislation::Question < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

  translates :title, touch: true
  include Globalizable

  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :legislation_questions
  belongs_to :process, foreign_key: "legislation_process_id", inverse_of: :questions

  has_many :question_options, -> { order(:id) }, class_name: "Legislation::QuestionOption", foreign_key: "legislation_question_id",
                                                 dependent: :destroy, inverse_of: :question
  has_many :answers, class_name: "Legislation::Answer", foreign_key: "legislation_question_id", dependent: :destroy, inverse_of: :question
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  accepts_nested_attributes_for :question_options, reject_if: proc { |attributes| attributes.all? { |k, v| v.blank? } }, allow_destroy: true

  validates :process, presence: true
  validates_translation :title, presence: true

  scope :sorted, -> { order("id ASC") }

  def next_question_id
    @next_question_id ||= process.questions.where("id > ?", id).sorted.limit(1).pluck(:id).first
  end

  def first_question_id
    @first_question_id ||= process.questions.sorted.limit(1).pluck(:id).first
  end

  def answer_for_user(user)
    answers.find_by(user: user)
  end

  def comments_for_verified_residents_only?
    true
  end

  def comments_closed?
    !comments_open?
  end

  def comments_open?
    process.debate_phase.open?
  end

  def best_comments
    comments.sort_by_supports.limit(3)
  end
end
