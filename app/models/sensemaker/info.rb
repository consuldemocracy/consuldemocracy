module Sensemaker
  class Info < ApplicationRecord
    self.table_name = "sensemaker_infos"

    # For storing the reference to the commentable object
    validates :commentable_type, presence: true
    validates :commentable_id, presence: true

    def self.for(kind, commentable_type, commentable_id)
      find_by(kind: kind, commentable_type: commentable_type, commentable_id: commentable_id)
    end
  end
end
