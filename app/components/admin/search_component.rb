class Admin::SearchComponent < ApplicationComponent
  attr_reader :label, :form_options

  def initialize(label:, url: nil, **form_options)
    @label = label
    @url = url
    @form_options = form_options
  end

  def url
    @url || request.path
  end

  private

    def search_terms
      params[:search]
    end

    def options
      { method: :get, role: "search" }.merge(form_options)
    end
end
