class Probe < ActiveRecord::Base
  has_many :probe_options, dependent: :destroy

  validates :codename, presence: true, uniqueness: true

  def option_voted_by(user)
    options_ids = probe_option_ids
    return nil if options_ids.blank?

    vote = user.votes.for_type(ProbeOption).where(votable_id: options_ids).first
    vote.blank? ? nil : vote.votable
  end
end