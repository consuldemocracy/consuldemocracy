module GeozonesHelper

  def geozone_name(geozonable)
    geozonable.geozone ? geozonable.geozone.name : t("geozones.none")
  end

  def geozone_select_options
    Geozone.all.order(name: :asc).collect { |g| [ g.name, g.id ] }
  end

  def my_geozone?(geozone, geozonable)
    geozone == geozonable.geozone
  end

end
