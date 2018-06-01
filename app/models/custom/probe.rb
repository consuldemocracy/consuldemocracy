class Probe < ActiveRecord::Base
  has_many :probe_options, dependent: :destroy

  validates :codename, presence: true, uniqueness: true

  def option_voted_by(user)
    ProbeSelection.where('probe_id = ? AND user_id = ?', id, user.id).limit(1).first.try(:probe_option)
  end
end
