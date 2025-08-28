module Sensemaker
  class Job < ApplicationRecord
    self.table_name = "sensemaker_jobs"

    belongs_to :user, optional: false

    # For storing the reference to the commentable object
    validates :commentable_type, presence: true
    validates :commentable_id, presence: true

    def started?
      started_at.present?
    end

    def finished?
      finished_at.present?
    end

    def errored?
      error.present?
    end
  end
end
