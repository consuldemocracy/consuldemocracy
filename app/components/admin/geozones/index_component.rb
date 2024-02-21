class Admin::Geozones::IndexComponent < ApplicationComponent
  include Header
  attr_reader :geozones

  def initialize(geozones)
    @geozones = geozones
  end

  private

    def title
      t("admin.geozones.index.title")
    end

    def yes_no_text(condition)
      if condition
        t("shared.yes")
      else
        t("shared.no")
      end
    end
    def geozones_data
       geozones.map do |geozone|
        {
         
          outline_points: geozone.outline_points,
          color: geozone.color,
          headings: geozones.where(id: geozone).map do | geozone|
             link_to(geozone.name, edit_admin_geozone_path(geozone.id))
          end
        }
       end
    end

end
