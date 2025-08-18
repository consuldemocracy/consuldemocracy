class Poll::Question < ApplicationRecord
  include Measurable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title, touch: true
  include Globalizable

  belongs_to :poll
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :poll_questions

  has_many :comments, as: :commentable, inverse_of: :commentable
  has_many :answers, class_name: "Poll::Answer"
  has_many :question_options, -> { order "given_order asc" },
           class_name: "Poll::Question::Option",
           inverse_of: :question,
           dependent: :destroy
  has_many :partial_results
  has_one :votation_type, as: :questionable, dependent: :destroy
  belongs_to :proposal

  validates_translation :title, presence: true, length: { minimum: 4 }
  validates :author, presence: true
  validates :poll_id, presence: true, if: proc { |question| question.poll.nil? }

  accepts_nested_attributes_for :question_options, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :votation_type

  delegate :multiple?, :vote_type, to: :votation_type, allow_nil: true

  scope :sort_for_list, -> { order(Arel.sql("poll_questions.proposal_id IS NULL"), :created_at) }
  scope :for_render,    -> { includes(:author, :proposal) }
  scope :for_physical_votes, -> {
    left_outer_joins(:votation_type)
      .where.not(votation_types: { vote_type: "essay" })
  }

  def copy_attributes_from_proposal(proposal)
    if proposal.present?
      self.author = proposal.author
      self.author_visible_name = proposal.author.name
      self.proposal_id = proposal.id
      send(:"#{localized_attr_name_for(:title, Globalize.locale)}=", proposal.title)
    end
  end

  def options_total_votes
    question_options.reduce(0) { |total, question_option| total + question_option.total_votes }
  end

  def most_voted_option_ids
    max_votes = question_options.map(&:total_votes).max
    question_options.select { |option| option.total_votes == max_votes }.map(&:id)
  end

  def possible_answers
    question_options.joins(:translations).pluck(:title)
  end

  def options_with_read_more?
    options_with_read_more.any?
  end

  def options_with_read_more
    question_options.select(&:with_read_more?)
  end

  def unique?
    votation_type.nil? || votation_type.unique?
  end

  def essay?
    votation_type&.essay?
  end

  def max_votes
    if multiple?
      votation_type.max_votes
    elsif unique?
      1
    elsif essay?
      nil
    end
  end

  def find_or_initialize_user_answer(user, option_id, text_answer)
    option = question_options.find_by(id: option_id) if option_id.present?

    answer = answers.find_or_initialize_by(find_by_attributes(user, option))

    if essay?
      answer.option = nil
      answer.answer = nil
      answer.text_answer = text_answer
    else
      answer.option = option
      answer.answer = option&.title
      if option&.open_text?
        answer.text_answer = text_answer
      else
        answer.text_answer = nil
      end
    end

    answer
  end

  private

    def find_by_attributes(user, option)
      case vote_type
      when "unique", nil
        { author: user }
      when "multiple"
        { author: user, answer: option&.title }
      when "essay"
        { author: user, option_id: nil }
      end
    end
end
