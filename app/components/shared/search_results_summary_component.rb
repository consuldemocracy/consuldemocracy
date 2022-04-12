class Shared::SearchResultsSummaryComponent < ApplicationComponent
  attr_reader :results, :search_terms, :advanced_search_terms

  def initialize(results:, search_terms:, advanced_search_terms:)
    @results = results
    @search_terms = search_terms
    @advanced_search_terms = advanced_search_terms
  end

  private

    def summary
      sanitize(t(
        "proposals.index.search_results",
        count: results.size,
        search_term: strip_tags(search_terms)
      ))
    end
end
