class Admin::VotationTypes::FieldsComponent < ApplicationComponent
  attr_reader :form

  def initialize(form:)
    @form = form
  end

  private

    def descriptions
      {
        unique: t("admin.polls.votation_type.unique_description"),
        multiple: t("admin.polls.votation_type.multiple_description"),
        open: t("admin.polls.votation_type.open_description")
      }
    end

    def description_tag(vote_type, text)
      tag.span(text, data: { vote_type: vote_type })
    end
end
