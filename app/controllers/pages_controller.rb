class PagesController < ApplicationController
  skip_authorization_check

  def accessibility
  end

  def census_terms
  end

  def conditions
  end

  def general_terms
  end

  def privacy
  end

  def coming_soon
  end

  def how_it_works
  end

  def how_to_use
  end

  def more_information
  end

  def opendata
  end

  def participation
  end

  def transparency
  end

  def proposals_info
  end

  def participation_facts
  end

  def participation_world
  end

  def blog
    redirect_to "http://diario.madrid.es/participa/"
  end
end
