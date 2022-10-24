module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model
    include SearchCache

    pg_search_scope :pg_search, ->(query) do
      cached_votes_up_present = column_names.include?("cached_votes_up")
      {
        against: :ignored, # not used since using a tsvector_column
        using: {
          tsearch: { tsvector_column: "tsv", dictionary: SearchDictionarySelector.call, prefix: true }
        },
        ignoring: :accents,
        ranked_by: "(:tsearch)",
        order_within_rank: (cached_votes_up_present ? "#{table_name}.cached_votes_up DESC" : nil),
        query: query
      }
    end
  end
end
