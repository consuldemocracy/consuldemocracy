class SDGManagement::Homepage::ShowComponent < ApplicationComponent
  include Header

  attr_reader :header_card, :phases

  def initialize(header_card, phases)
    @header_card = header_card
    @phases = phases
  end

  private

    def title
      t("sdg_management.homepage.title")
    end

    def create_card_text(phase)
      t("sdg_management.homepage.create_card", phase: phase.title.downcase)
    end

    def no_cards_message
      t("sdg_management.homepage.no_cards")
    end
end
