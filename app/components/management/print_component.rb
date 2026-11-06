class Management::PrintComponent < ApplicationComponent
  def initialize(text = nil)
    @text = text
  end

  def text
    @text ||= t("shared.print.print_button")
  end
end
