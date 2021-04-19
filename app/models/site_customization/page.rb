class SiteCustomization::Page < ApplicationRecord
  VALID_STATUSES = %w[draft published].freeze
  include Cardable
  translates :title,       touch: true
  translates :subtitle,    touch: true
  translates :content,     touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z\-_]*\Z/, message: :slug_format }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :published, -> { where(status: "published").sort_desc }
  scope :sort_asc, -> { order("id ASC") }
  scope :sort_desc, -> { order("id DESC") }
  scope :with_more_info_flag, -> { where(status: "published", more_info_flag: true).sort_asc }
  scope :with_same_locale, -> { joins(:translations).locale }
  scope :locale, -> { where("site_customization_page_translations.locale": I18n.locale) }

  #JHH:
  has_many :page_on_projects
  has_many :projects, through: :page_on_projects

  has_attached_file :imagen
  validates_attachment :imagen,
                     content_type: { content_type: /\Aimage\/.*\z/ },
                     size: { less_than: 1.megabyte }
  has_many :page_participants
  has_many :users, through: :page_participants

  after_save :save_page_participants, :delete_from_participants
  after_destroy :delete_page_participants

  attr_accessor :page_users_id, :delete_users_id

  def delete_page_participants
    PageParticipant.where(site_customization_pages_id: self).destroy_all
  end

  def delete_from_participants
    return if delete_users_id.nil? || delete_users_id.empty?

    delete_participants_array = delete_users_id.split(",")

    not_participant = PageParticipant.where(site_customization_pages_id: self)
    not_participant.where(user_id: delete_participants_array).destroy_all

  end

  def save_page_participants
    #Convertir en un arreglo alu10,alu20 => [alu10,alu20]

    return if page_users_id.nil? || page_users_id.empty?

    participants_array = page_users_id.split(",")
    #Iterarlo
    participants_array.each do |id_participant|
      #Crear ProposalParticipants
      PageParticipant.find_or_create_by(site_customization_pages_id: self.id, user_id: id_participant, slug: self.slug)
    end
  end
  #fin

  def url
    "/#{slug}"
  end
end
