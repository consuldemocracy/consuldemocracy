module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch
    include SearchCache

    pg_search_scope :pg_search, {
      against: :ignored, # not used since using a tsvector_column
      using: {
        tsearch: { tsvector_column: 'tsv', dictionary: "spanish", prefix: true }
      },
      ignoring: :accents,
      ranked_by: '(:tsearch)',
      order_within_rank: (column_names.include?('cached_votes_up') ? "#{table_name}.cached_votes_up DESC" : nil)
    }
  end

end
