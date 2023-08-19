class Admin::BudgetHeadings::HeadingsComponent < ApplicationComponent
  attr_reader :headings

  def initialize(headings)
    @headings = headings
  end

  private

    def group
      @group ||= headings.proxy_association.owner
    end

    def budget
      @budget ||= group.budget
    end

    def geozone_for(heading)
      if heading.geozone
        link_to heading.geozone.name, edit_admin_geozone_path(heading.geozone)
      else
        t("geozones.none")
      end
    end
end
