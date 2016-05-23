class Budget < ActiveRecord::Base

  VALID_PHASES = %W{on_hold accepting selecting balloting finished}

  validates :phase, inclusion: { in: VALID_PHASES }

  has_many :investments
  has_many :ballots
  has_many :headings

  def on_hold?
    phase == "on_hold"
  end

  def accepting?
    phase == "accepting"
  end

  def selecting?
    phase == "selecting"
  end

  def balloting?
    phase == "balloting"
  end

  def finished?
    phase == "finished"
  end

  def amount_available(heading)
    return 0 unless heading_ids.include?(heading.try(:id))
    heading.try(:price) || 10000 # FIXME
  end
end

