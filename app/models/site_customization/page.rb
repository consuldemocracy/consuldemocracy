class SiteCustomization::Page < ActiveRecord::Base
  VALID_STATUSES = %w(draft published)

  translates :title,       touch: true
  translates :subtitle,    touch: true
  translates :content,     touch: true
  globalize_accessors
  accepts_nested_attributes_for :translations, allow_destroy: true

  translation_class.instance_eval do
    validates :title, presence: true
  end

  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z\-_]*\Z/, message: :slug_format }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :published, -> { where(status: 'published').order('id DESC') }
  scope :with_more_info_flag, -> { where(status: 'published', more_info_flag: true).order('id ASC') }
  scope :with_same_locale, -> { joins(:translations).where("site_customization_page_translations.locale": I18n.locale) }

  def url
    "/#{slug}"
  end
end
