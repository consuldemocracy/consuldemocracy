class Legislation::Annotation < ActiveRecord::Base
  COMMENTS_PAGE_SIZE = 5
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  serialize :ranges, Array

  belongs_to :draft_version, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_draft_version_id'
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable, dependent: :destroy

  validates :text, presence: true
  validates :quote, presence: true
  validates :draft_version, presence: true
  validates :author, presence: true

  before_save :store_range, :store_context
  after_create :create_first_comment

  def store_range
    self.range_start = ranges.first["start"]
    self.range_start_offset = ranges.first["startOffset"]
    self.range_end = ranges.first["end"]
    self.range_end_offset = ranges.first["endOffset"]
  end

  def store_context
    html = draft_version.body_html
    doc = Nokogiri::HTML(html)
    selector = "/#{range_start}"
    text  = doc.xpath(selector).text
    text[quote] = "<span class=annotator-hl>#{quote}</span>"
    self.context = text
  end

  def create_first_comment
    comments.create(body: self.text, user: self.author)
  end

  def title
    text[0..50]
  end
end
