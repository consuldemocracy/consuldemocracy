class Budget
  class Heading < ActiveRecord::Base
    OSM_DISTRICT_LEVEL_ZOOM = 12.freeze

    include Sluggable

    translates :name, touch: true
    include Globalizable

    belongs_to :group

    has_many :investments
    has_many :content_blocks

    before_validation :assign_model_to_translations

    validates_translation :name, presence: true
    validates :group_id, presence: true
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :population, numericality: { greater_than: 0 }, allow_nil: true
    validates :latitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?([1-8]?\d(?:\.\d{1,})?|90(?:\.0{1,6})?)\z/
    validates :longitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?((?:1[0-7]|[1-9])?\d(?:\.\d{1,})?|180(?:\.0{1,})?)\z/

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :i18n,                  -> { includes(:translations) }
    scope :with_group,            -> { joins(group: :translations).where("budget_group_translations.locale = ?", I18n.locale) }
    scope :order_by_group_name,   -> { i18n.with_group.order("budget_group_translations.name DESC") }
    scope :order_by_heading_name, -> { i18n.with_group.order("budget_heading_translations.name") }
    scope :order_by_name,         -> { i18n.with_group.order_by_group_name.order_by_heading_name }
    scope :allow_custom_content,  -> { i18n.where(allow_custom_content: true).order(:name) }

    def name_scoped_by_group
      group.single_heading_group? ? name : "#{group.name}: #{name}"
    end

    def to_param
      slug
    end

    def can_be_deleted?
      investments.empty?
    end

    def city_heading?
      name == "Toda la ciudad"
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

  end
end
