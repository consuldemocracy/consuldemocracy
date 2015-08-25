require 'numeric'
class Debate < ActiveRecord::Base
  include ActsAsParanoidAliases
  default_scope { order(created_at: :desc) }

  apply_simple_captcha
  TITLE_LENGTH = Debate.columns.find { |c| c.name == 'title' }.limit

  acts_as_votable
  acts_as_commentable
  acts_as_taggable
  acts_as_paranoid column: :hidden_at

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :inappropiate_flags, :as => :flaggable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list

  scope :sorted_for_moderation, -> { order(inappropiate_flags_count: :desc, updated_at: :desc) }
  scope :pending, -> { where(archived_at: nil, hidden_at: nil) }
  scope :archived, -> { where("archived_at IS NOT NULL AND hidden_at IS NULL") }
  scope :flagged_as_inappropiate, -> { where("inappropiate_flags_count > 0") }
  scope :for_render, -> { includes(:tags) }

  # Ahoy setup
  visitable # Ahoy will automatically assign visit_id on create

  def self.search(params)
    if params[:tag]
      tagged_with(params[:tag])
    else
      all
    end
  end

  def self.sort_by(filter)
    case filter
    when 'votes'
      reorder(cached_votes_total: :desc)
    when 'news'
      reorder(created_at: :desc)
    when 'rated'
      reorder(cached_votes_up: :desc)
    end
  end

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
  end

  def total_votes
    cached_votes_total
  end

  def editable?
    total_votes == 0
  end

  def editable_by?(user)
    editable? && author == user
  end

  def description
    super.try :html_safe
  end

  def tag_list_with_limit(limit = nil)
    tags.most_used(limit).pluck :name
  end

  def tags_count_out_of_limit(limit = nil)
    return 0 unless limit

    count = tags.count - limit
    count < 0 ? 0 : count
  end

  def archived?
    archived_at.present?
  end

  def archive
    update(archived_at: Time.now)
  end

  protected

  def sanitize_description
    self.description = WYSIWYGSanitizer.new.sanitize(description)
  end

  def sanitize_tag_list
    self.tag_list = TagSanitizer.new.sanitize_tag_list(self.tag_list)
  end

end
