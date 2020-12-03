class Admin::SearchComponent < ApplicationComponent
  attr_reader :url, :label, :form_options

  def initialize(url:, label:, **form_options)
    @url = url
    @label = label
    @form_options = form_options
  end

  private

    def search_terms
      params[:search]
    end

    def options
      { method: :get, role: "search" }.merge(form_options)
    end
end
