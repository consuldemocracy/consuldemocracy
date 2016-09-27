class Enquiry < ActiveRecord::Base
  include Measurable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  has_many :comments, as: :commentable
  has_many :answers
  has_and_belongs_to_many :geozones
  belongs_to :proposal

  validates :title, presence: true
  validates :question, presence: true
  validates :summary, presence: true
  validates :author, presence: true
  validates :open_at, presence: true
  validates :closed_at, presence: true, date: { after_or_equal_to: :open_at}

  validates :title, length: { in: 4..Enquiry.title_max_length }
  validates :description, length: { maximum: Enquiry.description_max_length }
  validates :question, length: { in: 10..Enquiry.question_max_length }

  scope :sort_for_list, -> { order('proposal_id IS NULL', :open_at, :closed_at)}
  scope :for_render, -> { includes(:author, :proposal) }
  scope :opened,   -> { where('open_at <= ? and ? <= closed_at', Time.now, Time.now) }
  scope :incoming, -> { where('? < open_at', Time.now) }
  scope :expired,  -> { where('closed_at < ?', Time.now) }

  def opened?(timestamp = DateTime.now)
    open_at <= timestamp && timestamp <= closed_at
  end

  def incoming?(timestamp = DateTime.now)
    timestamp < open_at
  end

  def expired?(timestamp = DateTime.now)
    closed_at < timestamp
  end

  def description
    super.try :html_safe
  end

  def valid_answers
    (super.try(:split, ',') || []).map(&:strip)
  end

  def copy_attributes_from_proposal(proposal)
    if proposal.present?
      self.author = proposal.author
      self.proposal_id = proposal.id
      self.title = proposal.title
      self.description = proposal.description
      self.summary = proposal.summary
      self.question = proposal.question
      self.external_url = proposal.external_url
      self.geozones = Geozone.all
    end
  end


end
