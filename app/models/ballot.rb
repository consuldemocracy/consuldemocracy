class Ballot < ActiveRecord::Base
  belongs_to :user
  belongs_to :geozone

  has_many :ballot_lines, dependent: :destroy
  has_many :spending_proposals, through: :ballot_lines

  DISTRICT_BUDGETS = { "Arganzuela"          => 1556169,
                       "Barajas"             => 433589,
                       "Carabanchel"         => 3247830,
                       "Centro"              => 1353966,
                       "Chamartin"           => 1313747,
                       "Chamberí"            => 1259587,
                       "Ciudad Lineal"       => 2287757,
                       "Fuencarral-El Pardo" => 2441608,
                       "Hortaleza"           => 1827228,
                       "Latina"              => 2927200,
                       "Moncloa-Aravaca"     => 1129851,
                       "Moratalaz"           => 1067341,
                       "Puente de Vallecas"  => 3349186,
                       "Retiro"              => 1075155,
                       "Salamanca"           => 1286657,
                       "San Blas-Canillejas" => 1712043,
                       "Tetuán"              => 1677256,
                       "Usera"               => 1923216,
                       "Vicálvaro"           => 879529,
                       "Villa de Vallecas"   => 1220810,
                       "Villaverde"          => 2030275 }

  def amount_spent(geozone)
    spending_proposals.by_geozone(geozone).sum(:price).to_i
  end

  def amount_available(geozone)
    initial_budget(geozone) - amount_spent(geozone)
  end

  def total_amount_spent
    spending_proposals.sum(:price).to_i
  end

  def set_geozone(new_geozone)
    return if new_geozone.blank?
    self.update(geozone: new_geozone) unless new_geozone == geozone
  end

  def reset_geozone
    self.update(geozone: nil) if spending_proposals.district_wide.count == 0
  end

  def initial_budget(geozone)
    geozone.blank? ? 24000000 : DISTRICT_BUDGETS[geozone.name].to_i
  end

  def has_district_wide_votes?
    geozone_id.present?
  end

  def has_city_wide_votes?
    spending_proposals.city_wide.count > 0
  end

end
