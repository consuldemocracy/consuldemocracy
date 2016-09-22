class ProbeSelection < ActiveRecord::Base
  belongs_to :probe_option, counter_cache: true
  belongs_to :probe
  belongs_to :user

  validates :probe_option_id, uniqueness: { scope: [:probe_id, :user_id] }
end