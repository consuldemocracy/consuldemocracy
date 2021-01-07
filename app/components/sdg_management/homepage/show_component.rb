class SDGManagement::Homepage::ShowComponent < ApplicationComponent
  include Header

  attr_reader :phases

  def initialize(phases)
    @phases = phases
  end

  private

    def title
      t("sdg_management.homepage.title")
    end
end
