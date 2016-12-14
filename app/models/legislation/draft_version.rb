class Legislation::DraftVersion < ActiveRecord::Base
  VALID_STATUSES = %w(draft published)

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :process, class_name: 'Legislation::Process', foreign_key: 'legislation_process_id'

  validates :title, presence: true
  validates :body, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  def body_in_html
    body_html || Redcarpet::Markdown.new(Redcarpet::Render::HTML.new).render(body)
  end
end
