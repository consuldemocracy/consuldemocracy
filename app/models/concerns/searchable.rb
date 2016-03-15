module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch
    include SearchCache
   
    if self.table_name == "debates" or 
       self.table_name == "proposals" or 
       self.table_name == "comments"

      pg_search_scope :pg_search, {
        against: :ignored, # not used since using a tsvector_column
        using: {
          tsearch: { tsvector_column: 'tsv', dictionary: "spanish", prefix: true }
        },
        ignoring: :accents,
        ranked_by: '(:tsearch)',
        order_within_rank: "#{self.table_name}.cached_votes_up DESC"
      }
    elsif self.table_name == "spending_proposals"
      pg_search_scope :pg_search, {
        against: :ignored, # not used since using a tsvector_column
        using: {
          tsearch: { tsvector_column: 'tsv', dictionary: "spanish", prefix: true }
        },
        ignoring: :accents,
        ranked_by: '(:tsearch)',
        order_within_rank: "#{self.table_name}.title DESC"
      }

    elsif self.table_name == "users"
      pg_search_scope :pg_search, {
        against: :ignored, # not used since using a tsvector_column
        using: {
          tsearch: { tsvector_column: 'tsv', dictionary: "spanish", prefix: true }
        },
        ignoring: :accents,
        ranked_by: '(:tsearch)',
        order_within_rank: "#{self.table_name}.username DESC"
      }
    end
  end

end