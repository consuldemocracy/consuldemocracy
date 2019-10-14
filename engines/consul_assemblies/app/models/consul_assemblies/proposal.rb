module ConsulAssemblies
  class Proposal < ActiveRecord::Base

    PROPOSAL_ORIGIN = %w(user commission previous_meeting presidency)
    PROPOSAL_ACCEPTANCE_STATUSES = %w(undecided accepted rejected)

    belongs_to :meeting
    belongs_to :user
    has_many :attachments, as: :attachable

    before_validation :sanitize_conclusion

    validates :title, presence: true
    validates :meeting, associated: true
    validates :proposal_origin, inclusion: PROPOSAL_ORIGIN

    mount_uploader :attachment, AttachmentUploader

    accepts_nested_attributes_for :attachments,  :reject_if => :all_blank, :allow_destroy => true

    scope :accepted, -> { where(acceptance_status: 'accepted') }
    scope :declined, -> { where(acceptance_status: 'rejected').where(is_previous_meeting_acceptance: false) }
    scope :pending, -> { where(acceptance_status: 'undecided') }
    scope :to_approve, -> { where(is_previous_meeting_acceptance: true) }
    scope :not_previous, -> { where(is_previous_meeting_acceptance: false) }

    acts_as_list scope: :meeting

    def conclusion
      super.try :html_safe
    end

    def sanitize_conclusion
      self.conclusion = WYSIWYGSanitizer.new.sanitize(conclusion)
    end

    def archived?
      false
    end

    def no_attachment_versions
      true
    end
  end
end
