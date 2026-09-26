class Shared::SuggestComponent < ApplicationComponent
  attr_reader :resources, :search_terms

  def initialize(resources, search_terms:, resource_name: nil)
    @resources = resources
    @search_terms = search_terms
    @resource_name = resource_name
  end

  def render?
    search_terms && suggestions.any?
  end

  def resource_name
    @resource_name ||= resource_model.to_s.parameterize(separator: "_")
  end

  private

    def limit
      5
    end

    def suggestions
      @suggestions ||= resources.search(search_terms)
    end

    def resource_model
      resources.first.class
    end
end
