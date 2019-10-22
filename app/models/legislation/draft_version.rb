class Legislation::DraftVersion < ApplicationRecord
  VALID_STATUSES = %w[draft published]

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title,     touch: true
  translates :changelog, touch: true
  translates :body,      touch: true
  include Globalizable

  belongs_to :process, class_name: "Legislation::Process", foreign_key: "legislation_process_id"
  has_many :annotations, class_name: "Legislation::Annotation", foreign_key: "legislation_draft_version_id", dependent: :destroy

  validates_translation :title, presence: true
  validates_translation :body, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :published, -> { where(status: "published").order("id DESC") }

  def body_html
    renderer = Redcarpet::Render::HTML.new(with_toc_data: true)

    Redcarpet::Markdown.new(renderer).render(body)
  end

  def toc_html
    renderer = Redcarpet::Render::HTML_TOC.new(with_toc_data: true)

    Redcarpet::Markdown.new(renderer).render(body)
  end

  def display_title
    status == "draft" ? "#{title} *" : title
  end

  def total_comments
    annotations.sum(:comments_count)
  end
end
