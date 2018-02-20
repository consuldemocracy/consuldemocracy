class Newsletter < ActiveRecord::Base

  validates :subject, presence: true
  validates :segment_recipient, presence: true
  validates :from, presence: true
  validates :body, presence: true

  validates_format_of :from, :with => /@/

  def list_of_recipients
    UserSegments.send(segment_recipient).newsletter
  end

  def draft?
    sent_at.nil?
  end
end
