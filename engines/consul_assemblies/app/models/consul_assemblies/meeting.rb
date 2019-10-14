module ConsulAssemblies
  class Meeting < ActiveRecord::Base
    include Flaggable
    include Taggable
    include Sanitizable
    include Followable
    include ConsulAssemblies::Concerns::Notificable


    VALID_STATUSES = %w{open closed}

    belongs_to :assembly
    belongs_to :user
    has_many :attachments, as: :attachable
    has_many :proposals
    has_many :previous_meeting_acceptance_proposals,  -> { where is_previous_meeting_acceptance: true }, class_name: 'ConsulAssemblies::Proposal', foreign_key: :meeting_id
    has_many :comments, as: :commentable

    after_save :notify_to_followers

    validate :published_at_must_be_before_scheduled_at
    validates :assembly, presence: true, associated: true
    validates :description, presence: true
    validates :title, presence: true
    validates :user, presence: true

    mount_uploader :attachment, AttachmentUploader


    accepts_nested_attributes_for :attachments,  :reject_if => :all_blank, :allow_destroy => true
    accepts_nested_attributes_for :previous_meeting_acceptance_proposals,  :reject_if => :all_blank, :allow_destroy => true

    scope :published, -> { where('published_at <= ?', Time.current)}
    scope :without_held, -> { where('scheduled_at >= ?', Time.current)}
    scope :order_by_scheduled_at,  -> { order(scheduled_at: 'desc') }
    scope :with_hidden,  -> { order(scheduled_at: 'desc') }
    scope :for_render, -> {}

    def ready_for_held?
      Time.current >= close_accepting_proposals_at  && Time.current < scheduled_at
    end

    def author
      user
    end

    def unpublished?
      Time.current < published_at
    end

    def author_id
      user_id
    end

    def accepting_proposals?
      Time.current < close_accepting_proposals_at && accepts_proposals?
    end

    def held?
      Time.current > scheduled_at
    end

    def published_at_must_be_before_scheduled_at
      errors.add(:published_at, 'no puede estar antes que la fecha programada') if published_at > scheduled_at
    end

    def no_attachment_versions
      true
    end

    def archived?
      false
    end

    def comments_count
      0
    end
  end
end
