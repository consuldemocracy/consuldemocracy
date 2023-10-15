class Shared::AgreeWithTermsOfServiceFieldComponent < ApplicationComponent
  attr_reader :form

  def initialize(form)
    @form = form
  end

  private

    def label
      t("form.accept_terms",
        policy: link_to(t("form.policy"), "/privacy", target: "_blank"),
        conditions: link_to(t("form.conditions"), "/conditions", target: "_blank"))
    end
end
