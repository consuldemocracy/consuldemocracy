module Admin::SwitchText
  extend ActiveSupport::Concern

  def text
    if checked?
      t("shared.yes")
    else
      t("shared.no")
    end
  end

  private

    def checked?
      raise NotImplementedError, "method must be implemented in the included class"
    end
end
