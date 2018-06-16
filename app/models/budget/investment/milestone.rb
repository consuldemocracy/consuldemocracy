class Budget
  class Investment
    class Milestone < ActiveRecord::Base
      include Imageable
      include Documentable

      translates :title, :description, touch: true
      globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]

      belongs_to :investment

      validates :title, presence: true
      validates :description, presence: true
      validates :investment, presence: true
      validates :publication_date, presence: true

      scope :order_by_publication_date, -> { order(publication_date: :asc) }

      def self.title_max_length
        80
      end

      def self.max_documents_allowed
        Setting["documents_buget_investment_milestone_max_documents_allowed"].to_i
      end

      def self.max_file_size
        Setting["documents_buget_investment_milestone_max_file_size"].to_i.megabytes
      end

      def self.accepted_content_types
        [Setting["documents_buget_investment_milestone_accepted_content_types"]]
      end

    end
  end
end
