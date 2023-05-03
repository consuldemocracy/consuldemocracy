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
end
