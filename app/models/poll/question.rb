class Poll::Question < ActiveRecord::Base
  include Measurable
  include Searchable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :poll
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  has_many :comments, as: :commentable
  has_many :answers, class_name: 'Poll::Answer'
  has_many :question_answers, -> { order 'given_order asc' }, class_name: 'Poll::Question::Answer'
  has_many :partial_results
  belongs_to :proposal

  validates :title, presence: true
  validates :author, presence: true
  validates :poll_id, presence: true

  validates :title, length: { minimum: 4 }

  scope :by_poll_id,    ->(poll_id) { where(poll_id: poll_id) }

  scope :sort_for_list, -> { order('poll_questions.proposal_id IS NULL', :created_at)}
  scope :for_render,    -> { includes(:author, :proposal) }

  def self.search(params)
    results = all
    results = results.by_poll_id(params[:poll_id]) if params[:poll_id].present?
    results = results.pg_search(params[:search])   if params[:search].present?
    results
  end

  def searchable_values
    { title                 => 'A',
      proposal.try(:title)  => 'A',
      author.username       => 'C',
      author_visible_name   => 'C' }
  end

  def copy_attributes_from_proposal(proposal)
    if proposal.present?
      self.author = proposal.author
      self.author_visible_name = proposal.author.name
      self.proposal_id = proposal.id
      self.title = proposal.title
    end
  end

  delegate :answerable_by?, to: :poll

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?
    where(poll_id: Poll.answerable_by(user).pluck(:id))
  end

  def answers_total_votes
    question_answers.map { |a| Poll::Answer.where(question_id: self, answer: a.title).count }.sum
  end

end
