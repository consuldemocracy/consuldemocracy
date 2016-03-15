module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch
    include SearchCache

    ORDERS = {
      'comments'            => :cached_votes_up,
      'debates'             => :cached_votes_up,
      'proposals'           => :cached_votes_up,
      'spending_proposals'  => :title,
      'users'               => :username
    }

    ORDERS_TYPE = {
      'comments'            => "DESC",
      'debates'             => "DESC",
      'proposals'           => "DESC",
      'spending_proposals'  => "ASC",
      'users'               => "ASC"
    }

    pg_search_scope :pg_search, {
      against: :ignored, # not used since using a tsvector_column
      using: {
        tsearch: { tsvector_column: 'tsv', dictionary: "spanish", prefix: true }
      },
      ignoring: :accents,
      ranked_by: '(:tsearch)',
      order_within_rank: "#{self.table_name}.#{ORDERS[self.table_name]} #{ORDERS_TYPE[self.table_name]}"
    }
  end

end