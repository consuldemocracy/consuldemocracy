class Shared::AgreeWithTermsOfServiceFieldComponent < ApplicationComponent
  attr_reader :form
  use_helpers :new_window_link_to

  def initialize(form)
    @form = form
  end

  private

    def label
      t("form.accept_terms",
        policy: new_window_link_to(t("form.policy"), "/privacy"),
        conditions: new_window_link_to(t("form.conditions"), "/conditions"))
    end
end
