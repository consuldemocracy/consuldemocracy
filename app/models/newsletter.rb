class Newsletter < ActiveRecord::Base

  validates :subject, presence: true
  validates :segment_recipient, presence: true
  validates :from, presence: true
  validates :body, presence: true
  validate :validate_segment_recipient

  validates_format_of :from, :with => /@/

  def list_of_recipients
    UserSegments.send(segment_recipient).newsletter if valid_segment_recipient?
  end

  def valid_segment_recipient?
    segment_recipient && UserSegments.respond_to?(segment_recipient)
  end

  def draft?
    sent_at.nil?
  end

  private

  def validate_segment_recipient
    errors.add(:segment_recipient, :invalid) unless valid_segment_recipient?
  end
end
