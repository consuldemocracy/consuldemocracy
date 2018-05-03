class VolunteerPoll < ApplicationRecord

  VALID_DAYS = [
    "monday_13_morning",
    "monday_13_afternoon",
    "tuesday_14_morning",
    "tuesday_14_afternoon",
    "wednesday_15_morning",
    "wednesday_15_afternoon",
    "thursday_16_morning",
    "thursday_16_afternoon",
    "friday_17_morning",
    "friday_17_afternoon",
    "saturday_18_morning",
    "saturday_18_afternoon",
    "sunday_19_morning",
    "sunday_19_afternoon",
    "monday_20_morning"
  ]

  VALID_TURNS = [
    ['1 turno', (2..16).collect {|i| "#{i} turnos"}]
  ].flatten.freeze

  DISTRICTS = [ :any_district, :arganzuela, :barajas, :carabanchel, :centro,
                :chamartin, :chamberi, :ciudad_lineal, :fuencarral_el_pardo,
                :hortaleza, :latina, :moncloa_aravaca, :moratalaz,
                :puente_de_vallecas, :retiro, :salamanca,
                :san_blas_canillejas, :tetuan, :usera, :vicalvaro,
                :villa_de_vallecas, :villaverde ].freeze

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :first_name,      presence: true
  validates :last_name,       presence: true
  validates :document_number, presence: true
  validates :phone,           presence: true
  validates :turns, presence: true, inclusion: { in: VALID_TURNS }

end
