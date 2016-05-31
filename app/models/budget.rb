class Budget < ActiveRecord::Base

  include Sanitizable

  VALID_PHASES = %W{on_hold accepting selecting balloting finished}

  validates :phase, inclusion: { in: VALID_PHASES }
  validates :currency_symbol, presence: true

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

  def heading_price(heading)
    return price unless heading.present?
    heading_ids.include?(heading.id) ? heading.price : -1
  end
end

