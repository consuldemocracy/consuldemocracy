class Poll
  class Voter < ApplicationRecord
    VALID_ORIGINS = %w[web booth letter].freeze

    belongs_to :poll
    belongs_to :user
    belongs_to :geozone
    belongs_to :booth_assignment
    belongs_to :officer_assignment
    belongs_to :officer

    validates :poll_id, presence: true
    validates :user_id, presence: true
    validates :booth_assignment_id, presence: true, if: ->(voter) { voter.origin == "booth" }
    validates :officer_assignment_id, presence: true, if: ->(voter) { voter.origin == "booth" }

    validates :document_number, presence: true, unless: :skip_user_verification?
    validates :user_id, uniqueness: { scope: [:poll_id], message: :has_voted }
    validates :origin, inclusion: { in: ->(*) { VALID_ORIGINS }}

    before_validation :set_demographic_info, :set_document_info, :set_denormalized_booth_assignment_id

    scope :web,    -> { where(origin: "web") }
    scope :booth,  -> { where(origin: "booth") }
    scope :letter, -> { where(origin: "letter") }

    def set_demographic_info
      return if user.blank?

      self.gender  = user.gender
      self.age     = user.age
      self.geozone = user.geozone
    end

    def set_document_info
      return if user.blank?

      current_user = User.with_hidden
                         .where(document_number: self.document_number)
                         .first
      unless current_user&.paranoia_destroyed?
        self.document_type   = user.document_type
        self.document_number = user.document_number
      end
    end

    def skip_user_verification?
      Setting["feature.user.skip_verification"].present?
    end

    private

      def set_denormalized_booth_assignment_id
        self.booth_assignment_id ||= officer_assignment&.booth_assignment_id
      end
  end
end

# == Schema Information
#
# Table name: poll_voters
#
#  id                    :integer          not null, primary key
#  document_number       :string
#  document_type         :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  poll_id               :integer          not null
#  booth_assignment_id   :integer
#  age                   :integer
#  gender                :string
#  geozone_id            :integer
#  answer_id             :integer
#  officer_assignment_id :integer
#  user_id               :integer
#  origin                :string
#  officer_id            :integer
#  token                 :string
#
