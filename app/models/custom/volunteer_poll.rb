class VolunteerPoll < ActiveRecord::Base

  VALID_AVAILABILITY_WEEKS = [
    'mañanas', 'tardes', 'mañanas y tardes', 'no estaré disponible ningún día de lunes a viernes'
  ].freeze

  VALID_AVAILABILITY_WEEKENDS = [
    'mañanas', 'tardes', 'mañanas y tardes', 'no estaré disponible ni sábado ni domingo'
  ].freeze

  VALID_TURNS = [
    '1 turno', '2 turnos', '3 turnos', '4 o más turnos'
  ].freeze

  DISTRICTS = [ :any_district, :arganzuela, :barajas, :carabanchel, :centro,
                :chamartin, :chamberi, :ciudad_lineal, :fuencarral_el_pardo,
                :hortaleza, :latina, :moncloa_aravaca, :moratalaz,
                :puente_de_vallecas, :retiro, :salamanca,
                :san_blas_canillejas, :tetuan, :usera, :vicalvaro,
                :villa_de_vallecas, :villaverde ].freeze

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :availability_week, presence: true, inclusion: { in: VALID_AVAILABILITY_WEEKS }
  validates :availability_weekend, presence: true, inclusion: { in: VALID_AVAILABILITY_WEEKENDS }
  validates :turns, presence: true, inclusion: { in: VALID_TURNS }

end
