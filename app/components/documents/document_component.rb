class Documents::DocumentComponent < ApplicationComponent
  attr_reader :document, :show_destroy_link
  alias_method :show_destroy_link?, :show_destroy_link
  delegate :can?, to: :helpers

  def initialize(document, show_destroy_link: false)
    @document = document
    @show_destroy_link = show_destroy_link
  end
end
