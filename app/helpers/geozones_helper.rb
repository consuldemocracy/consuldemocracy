module GeozonesHelper
  def geozone_name(geozonable)
    geozonable.geozone ? geozonable.geozone.name : t("geozones.none")
  end

  def geozone_select_options
    Geozone.order(name: :asc).map { |g| [g.name, g.id] }
  end
end
