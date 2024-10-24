class Admin::VotationTypes::FieldsComponent < ApplicationComponent
  attr_reader :form

  def initialize(form:)
    @form = form
  end
end
