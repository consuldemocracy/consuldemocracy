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

  #Acceso a los usuarios
  attr_accessor :user_elements, :user_ids
  attr_accessor :delete_user_elements, :delete_user_ids

  after_destroy :delete_participants
  #Fin

  #Funciones para los usuarios
    # Eliminar todos los participantes
    def delete_participants
      PageParticipant.where(site_customization_pages_id: self).destroy_all
    end
      # Eliminar los participantes seleccionados
    def delete_component(delete_user_elements)
      if !delete_user_elements.nil?
        delete_element = PageParticipant.where(site_customization_pages_id: self.id)
        delete_element.where(user_id: delete_user_elements).destroy_all
      end
    end

        # Añadir los participantes
    def save_component(user_elements)
      if !user_elements.nil?
        user_elements.each do |user_id|
          PageParticipant.find_or_create_by(site_customization_pages_id: self.id, user_id: user_id)
        end
      end
    end
    #Fin

  def url
    "/#{slug}"
  end
end
