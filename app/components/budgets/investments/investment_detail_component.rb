class Budgets::Investments::InvestmentDetailComponent < ApplicationComponent
  attr_reader :investment, :preview
  alias_method :preview?, :preview
  delegate :auto_link_already_sanitized_html, :map_location_available?,
           :render_image, :render_map, :wysiwyg, to: :helpers

  def initialize(investment, preview: false)
    @investment = investment
    @preview = preview
  end
end
