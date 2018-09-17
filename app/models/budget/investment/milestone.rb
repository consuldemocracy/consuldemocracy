class Budget
  class Investment
    class Milestone < ActiveRecord::Base
      include Imageable
      include Documentable
      documentable max_documents_allowed: 3,
                   max_file_size: 3.megabytes,
                   accepted_content_types: [ "application/pdf" ]

      translates :title, :description, touch: true
      globalize_accessors

      belongs_to :investment
      belongs_to :status, class_name: 'Budget::Investment::Status'

      validates :title, presence: true
      validates :investment, presence: true
      validates :publication_date, presence: true
      validate :description_or_status_present?

      scope :order_by_publication_date, -> { order(publication_date: :asc) }

      def self.title_max_length
        80
      end

      def description_or_status_present?
        unless description.present? || status_id.present?
          errors.add(:description)
        end
      end
    end
  end
end
