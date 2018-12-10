class Poll::Stats
  include Statisticable
  include StatsHelper
  alias_method :poll, :resource

  def self.stats_methods
    %i[total_participants total_participants_web total_web_valid total_web_white total_web_null
       total_participants_booth total_booth_valid total_booth_white total_booth_null
       total_valid_votes total_white_votes total_null_votes valid_percentage_web valid_percentage_booth
       total_valid_percentage white_percentage_web white_percentage_booth total_white_percentage
       null_percentage_web null_percentage_booth total_null_percentage total_participants_web_percentage
       total_participants_booth_percentage]
  end

  private

    def total_participants
      total_participants_web + total_participants_booth
    end

    def total_participants_web
      total_web_valid + total_web_white + total_web_null
    end

    def total_participants_web_percentage
      calculate_percentage(total_participants_web, total_participants)
    end

    def total_participants_booth
      total_booth_valid + total_booth_white + total_booth_null
    end

    def total_participants_booth_percentage
      calculate_percentage(total_participants_booth, total_participants)
    end

    def total_web_valid
      voters.where(origin: "web").count - total_web_white
    end

    def valid_percentage_web
      calculate_percentage(total_web_valid, total_valid_votes)
    end

    def total_web_white
      0
    end

    def white_percentage_web
      calculate_percentage(total_web_white, total_white_votes)
    end

    def total_web_null
      0
    end

    def null_percentage_web
      calculate_percentage(total_web_null, total_null_votes)
    end

    def total_booth_valid
      recounts.sum(:total_amount)
    end

    def valid_percentage_booth
      calculate_percentage(total_booth_valid, total_valid_votes)
    end

    def total_booth_white
      recounts.sum(:white_amount)
    end

    def white_percentage_booth
      calculate_percentage(total_booth_white, total_white_votes)
    end

    def total_booth_null
      recounts.sum(:null_amount)
    end

    def null_percentage_booth
      calculate_percentage(total_booth_null, total_null_votes)
    end

    def total_valid_votes
      total_web_valid + total_booth_valid
    end

    def total_valid_percentage
      calculate_percentage(total_valid_votes, total_participants)
    end

    def total_white_votes
      total_web_white + total_booth_white
    end

    def total_white_percentage
      calculate_percentage(total_white_votes, total_participants)
    end

    def total_null_votes
      total_web_null + total_booth_null
    end

    def total_null_percentage
      calculate_percentage(total_null_votes, total_participants)
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
