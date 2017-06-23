class ProposalCalculator
  attr_accessor :spending_proposal

  DISTRICT_MINIMUM_VOTES = {
    "Arganzuela"            => 40,
    "Barajas"               => 10,
    "Carabanchel"           => 37,
    "Centro"                => 49,
    "Chamartín"             => 31,
    "Chamberí"              => 28,
    "Ciudad Lineal"         => 43,
    "Fuencarral-El Pardo"   => 56,
    "Hortaleza"             => 39,
    "Latina"                => 49,
    "Moncloa-Aravaca"       => 57,
    "Moratalaz"             => 16,
    "Puente de Vallecas"    => 39,
    "Retiro"                => 34,
    "Salamanca"             => 26,
    "San Blas-Canillejas"   => 24,
    "Tetuán"                => 31,
    "Usera"                 => 34,
    "Vicálvaro"             => 20,
    "Villa de Vallecas"     => 24,
    "Villaverde"            => 27 }

  RECLASSIFIED = [282, 4517, 4528, 4334, 1025, 3097, 344, 4310, 3043, 3245, 3785, 1941, 796, 3220, 855, 3365, 2847, 792, 4540, 4966, 4819, 514, 4973, 2246, 3981, 3868, 542, 2100, 3296, 4735, 3488, 4562, 3722, 4975, 4554, 2522, 1532, 2580, 859, 2581, 3100, 29, 3372, 3369, 2915, 460, 4083, 4058, 3542, 2314, 175, 2337, 3454, 1265, 593, 731, 3012, 4272, 3064, 2901, 211, 4816, 549, 2958, 3479, 3431, 2529, 5056, 4182, 2793, 5078, 5200, 5317, 5310, 3747, 5310, 5406, 5230, 3271, 3496, 5148, 4133, 1819, 3175, 1668, 4225, 975, 4785, 644, 3252, 2981, 3168, 2447, 4683, 3471, 1830, 339, 913, 3470, 4232, 924, 3760, 3419, 3417]

  def initialize(spending_proposal)
    @spending_proposal = spending_proposal
  end

  def mark_as_undecided?
    has_votes? && insufficient_votes? && !reclassified?
  end

  def has_votes?
    spending_proposal.total_votes > 0
  end

  def insufficient_votes?
    spending_proposal.total_votes < minimum_votes?(spending_proposal.geozone)
  end

  def feasible?
    spending_proposal.feasible?
  end

  def reclassified?
    RECLASSIFIED.include?(spending_proposal.id)
  end

  def minimum_votes?(geozone)
    geozone.blank? ? 52 : DISTRICT_MINIMUM_VOTES[geozone.name].to_i
  end

end

