class Poll::Question < ApplicationRecord
  include Measurable
  include Searchable

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
  validate :validate_votation_type_essay

  after_save :votation_type_essay_auto_option

  accepts_nested_attributes_for :question_options, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :votation_type

  delegate :multiple?, :vote_type, to: :votation_type, allow_nil: true

  scope :by_poll_id,    ->(poll_id) { where(poll_id: poll_id) }

  scope :sort_for_list, -> { order(Arel.sql("poll_questions.proposal_id IS NULL"), :created_at) }
  scope :for_render,    -> { includes(:author, :proposal) }

  def self.search(params)
    results = all
    results = results.by_poll_id(params[:poll_id]) if params[:poll_id].present?
    results = results.pg_search(params[:search])   if params[:search].present?
    results
  end

  def searchable_values
    { title => "A",
      proposal&.title => "A",
      author.username => "C",
      author_visible_name => "C" }
  end

  def copy_attributes_from_proposal(proposal)
    if proposal.present?
      self.author = proposal.author
      self.author_visible_name = proposal.author.name
      self.proposal_id = proposal.id
      send(:"#{localized_attr_name_for(:title, Globalize.locale)}=", proposal.title)
    end
  end

  delegate :answerable_by?, to: :poll

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?

    where(poll_id: Poll.answerable_by(user).pluck(:id))
  end

  def options_total_votes
    question_options.reduce(0) { |total, question_option| total + question_option.total_votes }
  end

  def most_voted_option_id
    question_options.max_by(&:total_votes)&.id
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

  def essay_option
    question_options.where(open_text: true).first
  end

  def unique?
    votation_type.nil? || votation_type.unique?
  end

  def essay?
    votation_type.essay?
  end

  def max_votes
    if multiple?
      votation_type.max_votes
    else
      1
    end
  end

  def find_or_initialize_user_answer(user, option_id, text_answer)
    option = question_options.find(option_id)

    answer = answers.find_or_initialize_by(find_by_attributes(user, option))
    answer.option = option
    answer.answer = option.title
    if option.open_text && text_answer
      answer.text_answer = text_answer
    end
    answer
  end

  private

    def find_by_attributes(user, option)
      case vote_type
      when "unique", "essay", nil
        { author: user }
      when "multiple"
        { author: user, answer: option.title }
      end
    end

    def votation_type_essay_auto_option
      if essay? && question_options.count == 0
        question_options.create!(title: 'open text', open_text: true);
      end
    end

    def validate_votation_type_essay
      if essay? && ( question_options.count > 1 || question_options.where(open_text: false).count > 1 )
        errors.add(:votation_type, "can't change to type essay, multiple answers already exist on question")
      end
    end
end
