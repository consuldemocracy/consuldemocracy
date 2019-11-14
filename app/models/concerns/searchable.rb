module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch
    include SearchCache

    pg_search_scope :pg_search, ->(query) do
      {
        against: :ignored, # not used since using a tsvector_column
        using: {
          tsearch: { tsvector_column: "tsv", dictionary: SearchDictionarySelector.call, prefix: true }
        },
        ignoring: :accents,
        ranked_by: "(:tsearch)",
        order_within_rank: (column_names.include?("cached_votes_up") ? "#{table_name}.cached_votes_up DESC" : nil),
        query: query
      }
    end
  end
end
