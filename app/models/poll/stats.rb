class Poll::Stats
  include Statisticable
  alias_method :poll, :resource

  def self.stats_methods
    super +
      %i[total_valid_votes total_white_votes total_null_votes
         total_participants_web total_web_valid total_web_white total_web_null
         total_participants_booth total_booth_valid total_booth_white total_booth_null
         total_participants_web_percentage total_participants_booth_percentage
         valid_percentage_web valid_percentage_booth total_valid_percentage
         white_percentage_web white_percentage_booth total_white_percentage
         null_percentage_web null_percentage_booth total_null_percentage]
  end

  def total_participants
    total_participants_web + total_participants_booth
  end

  %i[web booth].each do |channel|
    define_method :"total_participants_#{channel}" do
      send(:"total_#{channel}_valid") +
        send(:"total_#{channel}_white") +
        send(:"total_#{channel}_null")
    end

    define_method :"total_participants_#{channel}_percentage" do
      calculate_percentage(send(:"total_participants_#{channel}"), total_participants)
    end
  end

  def total_web_valid
    voters.where(origin: "web").count - total_web_white
  end

  def total_web_white
    0
  end

  def total_web_null
    0
  end

  def total_booth_valid
    recounts.sum(:total_amount)
  end

  def total_booth_white
    recounts.sum(:white_amount)
  end

  def total_booth_null
    recounts.sum(:null_amount)
  end

  %i[valid white null].each do |type|
    %i[web booth].each do |channel|
      define_method :"#{type}_percentage_#{channel}" do
        calculate_percentage(send(:"total_#{channel}_#{type}"), send(:"total_#{type}_votes"))
      end
    end

    define_method :"total_#{type}_votes" do
      send(:"total_web_#{type}") + send(:"total_booth_#{type}")
    end

    define_method :"total_#{type}_percentage" do
      calculate_percentage(send(:"total_#{type}_votes"), total_participants)
    end
  end

  private

    def participants
      User.where(id: voters.pluck(:user_id))
    end

    def voters
      poll.voters
    end

    def recounts
      poll.recounts
    end

    stats_cache(*stats_methods)
    stats_cache :voters, :recounts

    def stats_cache(key, &block)
      Rails.cache.fetch("polls_stats/#{poll.id}/#{key}/v12", &block)
    end

end
