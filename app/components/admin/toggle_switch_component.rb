class Admin::ToggleSwitchComponent < ApplicationComponent
  attr_reader :action, :record, :pressed, :options
  alias_method :pressed?, :pressed

  def initialize(action, record, pressed:, **options)
    @action = action
    @record = record
    @pressed = pressed
    @options = options
  end

  private

    def text
      if pressed?
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    def default_options
      {
        text: text,
        method: :patch,
        remote: true,
        "aria-pressed": pressed?,
        form_class: "toggle-switch"
      }
    end
end
