class Legislation::DraftVersion < ApplicationRecord
  VALID_STATUSES = %w[draft published].freeze

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title,     touch: true
  translates :changelog, touch: true
  translates :body,      touch: true
  include Globalizable

  belongs_to :process, foreign_key: "legislation_process_id", inverse_of: :draft_versions
  has_many :annotations,
    foreign_key: "legislation_draft_version_id",
    inverse_of:  :draft_version,
    dependent:   :destroy

  validates_translation :title, presence: true
  validates_translation :body, presence: true
  validates :status, presence: true, inclusion: { in: ->(*) { VALID_STATUSES }}

  scope :published, -> { where(status: "published").order("id DESC") }

  def body_html
    MarkdownConverter.new(body, tables: true, with_toc_data: true).render
  end

  def toc_html
    MarkdownConverter.new(body).render_toc
  end

  def display_title
    status == "draft" ? "#{title} *" : title
  end

  def total_comments
    annotations.sum(:comments_count)
  end

  def best_comments
    Comment.where(commentable: annotations, ancestry: nil).sort_by_supports.limit(10)
  end
end
