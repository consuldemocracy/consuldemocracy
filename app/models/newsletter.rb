class Newsletter < ActiveRecord::Base
  enum segment_recipient: { all_users: 1,
                            proposal_authors: 2,
                            investment_authors: 3,
                            feasible_and_undecided_investment_authors: 4,
                            selected_investment_authors: 5,
                            winner_investment_authors: 6 }

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
