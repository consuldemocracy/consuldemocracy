class Legislation::DraftVersion < ActiveRecord::Base
  VALID_STATUSES = %w(draft published)

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :process, class_name: 'Legislation::Process', foreign_key: 'legislation_process_id'

  validates :title, presence: true
  validates :body, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  def body_in_html
    renderer = Redcarpet::Render::HTML.new(with_toc_data: true)
    toc_renderer = Redcarpet::Render::HTML_TOC.new(with_toc_data: true)

    body_html = Redcarpet::Markdown.new(renderer).render(body)
    toc = Redcarpet::Markdown.new(toc_renderer).render(body)

    return toc, body_html
  end
end
