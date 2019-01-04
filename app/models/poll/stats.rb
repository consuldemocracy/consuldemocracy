class Poll::Stats
  include Statisticable
  alias_method :poll, :resource

  CHANNELS = %i[web booth mail]

  def self.stats_methods
    super +
      %i[total_valid_votes total_white_votes total_null_votes
         total_participants_web total_web_valid total_web_white total_web_null
         total_participants_booth total_booth_valid total_booth_white total_booth_null
         total_participants_mail total_mail_valid total_mail_white total_mail_null
         total_participants_web_percentage total_participants_booth_percentage
         total_participants_mail_percentage
         valid_percentage_web valid_percentage_booth valid_percentage_mail total_valid_percentage
         white_percentage_web white_percentage_booth white_percentage_mail total_white_percentage
         null_percentage_web null_percentage_booth null_percentage_mail total_null_percentage
         total_male_web total_male_booth total_male_mail
         total_female_web total_female_booth total_female_mail
         male_web_percentage male_booth_percentage male_mail_percentage
         female_web_percentage female_booth_percentage female_mail_percentage]
  end

  def total_participants
    total_participants_web + total_participants_booth
  end

  CHANNELS.each do |channel|
    define_method :"total_participants_#{channel}" do
      send(:"total_#{channel}_valid") +
        send(:"total_#{channel}_white") +
        send(:"total_#{channel}_null")
    end

    define_method :"total_participants_#{channel}_percentage" do
      calculate_percentage(send(:"total_participants_#{channel}"), total_participants)
    end

    define_method :"#{channel}_participants" do
      User.where(id: voters.where(origin: channel).pluck(:user_id))
    end

    %i[male female].each do |gender|
      define_method :"total_#{gender}_#{channel}" do
        send(:"#{channel}_participants").public_send(gender).count
      end

      define_method :"#{gender}_#{channel}_percentage" do
        calculate_percentage(
          send(:"total_#{gender}_#{channel}"),
          send(:"total_#{gender}_participants")
        )
      end
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

  def total_mail_valid
    0 # TODO
  end

  def total_mail_white
    0 # TODO
  end

  def total_mail_null
    0 # TODO
  end

  %i[valid white null].each do |type|
    CHANNELS.each do |channel|
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
