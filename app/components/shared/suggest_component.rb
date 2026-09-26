class Shared::SuggestComponent < ApplicationComponent
  attr_reader :resources, :search_terms
  delegate :resource_name, :resource_model, to: :helpers

  def initialize(resources, search_terms:)
    @resources = resources
    @search_terms = search_terms
  end

  def render?
    search_terms && suggestions.any?
  end

  private

    def limit
      5
    end

    def suggestions
      @suggestions ||= resources.search(search_terms)
    end
end
