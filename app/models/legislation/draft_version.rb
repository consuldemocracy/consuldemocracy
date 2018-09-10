class Legislation::DraftVersion < ActiveRecord::Base
  VALID_STATUSES = %w(draft published)

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title,     touch: true
  translates :changelog, touch: true
  translates :body,      touch: true
  translates :body_html, touch: true
  translates :toc_html,  touch: true
  globalize_accessors

  belongs_to :process, class_name: 'Legislation::Process', foreign_key: 'legislation_process_id'
  has_many :annotations, class_name: 'Legislation::Annotation', foreign_key: 'legislation_draft_version_id', dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :published, -> { where(status: 'published').order('id DESC') }

  before_save :render_html

  def render_html
    renderer = Redcarpet::Render::HTML.new(with_toc_data: true)
    toc_renderer = Redcarpet::Render::HTML_TOC.new(with_toc_data: true)

    if body_changed?
      self.body_html = Redcarpet::Markdown.new(renderer).render(body)
      self.toc_html = Redcarpet::Markdown.new(toc_renderer).render(body)
    end

    translations.each do |translation|
      if translation.body_changed?
        translation.body_html = Redcarpet::Markdown.new(renderer).render(translation.body)
        translation.toc_html = Redcarpet::Markdown.new(toc_renderer).render(translation.body)
      end
    end
  end

  def display_title
    status == 'draft' ? "#{title} *" : title
  end

  def total_comments
    annotations.sum(:comments_count)
  end
end
