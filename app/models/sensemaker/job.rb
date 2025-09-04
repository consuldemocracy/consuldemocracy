module Sensemaker
  class Job < ApplicationRecord
    self.table_name = "sensemaker_jobs"

    belongs_to :user, optional: false

    # For storing the reference to the commentable object
    validates :commentable_type, presence: true
    validates :commentable_id, presence: true

    belongs_to :commentable, polymorphic: true

    def started?
      started_at.present?
    end

    def finished?
      finished_at.present?
    end

    def errored?
      error.present?
    end

    def status
      if errored?
        "Failed"
      elsif finished?
        "Completed"
      elsif started?
        "Running"
      else
        "Pending"
      end
    end

    def self.unfinished
      where(finished_at: nil)
    end
  end
end
