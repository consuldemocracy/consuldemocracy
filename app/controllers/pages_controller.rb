class PagesController < ApplicationController
  skip_authorization_check

  def census_terms
  end

  def conditions
  end

  def general_terms
  end

  def privacy
  end

  def cooming_soon
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

  def blog
    redirect_to "http://diario.madrid.es/blog/category/gobiernoabierto/"
  end
end
