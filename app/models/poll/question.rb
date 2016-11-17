class Poll::Question < ActiveRecord::Base
  include Measurable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :poll
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  has_many :comments, as: :commentable
  has_many :answers
  has_many :partial_results
  has_and_belongs_to_many :geozones
  belongs_to :proposal

  validates :title, presence: true
  validates :summary, presence: true
  validates :author, presence: true

  validates :title, length: { in: 4..Poll::Question.title_max_length }
  validates :description, length: { maximum: Poll::Question.description_max_length }

  scope :sort_for_list, -> { order('poll_questions.proposal_id IS NULL', :created_at)}
  scope :for_render, -> { includes(:author, :proposal) }
  scope :by_geozone, -> (geozone_id) { joins(:geozones).where(geozones: {id: geozone_id}) }

  def description
    super.try :html_safe
  end

  def valid_answers
    (super.try(:split, ',').compact || []).map(&:strip)
  end

  def copy_attributes_from_proposal(proposal)
    if proposal.present?
      self.author = proposal.author
      self.author_visible_name = proposal.author.name
      self.proposal_id = proposal.id
      self.title = proposal.title
      self.description = proposal.description
      self.summary = proposal.summary
      self.question = proposal.question
      self.all_geozones = true
      self.valid_answers = I18n.t('poll_questions.default_valid_answers')
    end
  end

  def answerable_by?(user)
    poll.answerable_by?(user) && (self.all_geozones || self.geozone_ids.include?(user.geozone_id))
  end

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?

    joins('LEFT JOIN "geozones_poll_questions" ON "geozones_poll_questions"."question_id" = "poll_questions"."id"')
      .where('poll_questions.poll_id IN (?) AND (poll_questions.all_geozones = ? OR geozones_poll_questions.geozone_id = ?)',
             Poll.answerable_by(user).pluck(:id),
             true,
             user.geozone_id || -1) # user.geozone_id can be nil, which would throw errors on sql
      .group('poll_questions.id')
  end

end
