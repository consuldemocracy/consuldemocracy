class GeozoneStats
  attr_reader :geozone, :participants

  def initialize(geozone, participants)
    @geozone = geozone
    @participants = participants
  end

  def geozone_participants
    participants.where(geozone: geozone)
  end

  def name
    geozone.name
  end

  def count
    geozone_participants.count
  end

  def percentage
    PercentageCalculator.calculate(count, participants.count)
  end
end
