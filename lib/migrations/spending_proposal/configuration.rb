### This is the configuration file to migrate spending proposals to budget investments
### The values that you see are the ones used in Madrid's fork.
### Please update them accordingly for your city.

module Migrations::SpendingProposal::Configuration

  # Name you want to give to the budget that you are migrating.
  def budget_name
    "2016"
  end

  # Budget to be created
  def budget
    ::Budget.where(slug: budget_name).first
  end

  # This is a special heading, that many forks use to represent their City Heading.
  def city_heading
    "Toda la ciudad"
  end

  # The name for the disticts group
  def districts_heading
    "Distritos"
  end

  # Total money avaiable for the City Heading.
  def city_price
    24000000
  end

  # Money available in every district heading
  def price_by_heading
    {
      "Arganzuela"          => 1556169,
      "Barajas"             => 433589,
      "Carabanchel"         => 3247830,
      "Centro"              => 1353966,
      "Chamartín"           => 1313747,
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
      "Villaverde"          => 2030275
    }
  end

  # Population in every district heading
  def population_by_heading
    {
      "Arganzuela"          => 131429,
      "Barajas"             =>  37725,
      "Carabanchel"         => 205197,
      "Centro"              => 120867,
      "Chamartín"           => 123099,
      "Chamberí"            => 122280,
      "Ciudad Lineal"       => 184285,
      "Fuencarral-El Pardo" => 194232,
      "Hortaleza"           => 146471,
      "Latina"              => 204427,
      "Moncloa-Aravaca"     =>  99274,
      "Moratalaz"           =>  82741,
      "Puente de Vallecas"  => 194314,
      "Retiro"              => 103666,
      "Salamanca"           => 126699,
      "San Blas-Canillejas" => 127800,
      "Tetuán"              => 133972,
      "Usera"               => 112158,
      "Vicálvaro"           =>  55783,
      "Villa de Vallecas"   =>  82504,
      "Villaverde"          => 117478
    }
  end

end
