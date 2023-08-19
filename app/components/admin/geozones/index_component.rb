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
end
