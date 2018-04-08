class Poll
  class Stats

    def initialize(poll)
      @poll = poll
    end

    def generate
      stats = %w[total_participants total_participants_web total_web_valid total_web_white total_web_null
                 total_participants_booth total_booth_valid total_booth_white total_booth_null
                 total_valid_votes total_white_votes total_null_votes valid_percentage_web valid_percentage_booth
                 total_valid_percentage white_percentage_web white_percentage_booth total_white_percentage
                 null_percentage_web null_percentage_booth total_null_percentage total_participants_web_percentage
                 total_participants_booth_percentage]
      stats.map { |stat_name| [stat_name.to_sym, send(stat_name)] }.to_h
    end

    private

      def total_participants
        stats_cache('total_participants') { total_participants_web + total_participants_booth }
      end

      def total_participants_web
        stats_cache('total_participants_web') { total_web_valid + total_web_white + total_web_null }
      end

      def total_participants_web_percentage
        stats_cache('total_participants_web_percentage') do
          total_participants.zero? ? 0 : total_participants_web * 100 / total_participants
        end
      end

      def total_participants_booth
        stats_cache('total_participants_booth') { voters.where(origin: 'booth').count }
      end

      def total_participants_booth_percentage
        stats_cache('total_participants_booth_percentage') do
          total_participants.zero? ? 0 : total_participants_booth * 100 / total_participants.to_f
        end
      end

      def total_web_valid
        stats_cache('total_web_valid') { voters.where(origin: 'web').count }
      end

      def valid_percentage_web
        stats_cache('valid_percentage_web') do
          total_valid_votes.zero? ? 0 : total_web_valid * 100 / total_valid_votes.to_f
        end
      end

      def total_web_white
        stats_cache('total_web_white') { 0 }
      end

      def white_percentage_web
        stats_cache('white_percentage_web') { 0 }
      end

      def total_web_null
        stats_cache('total_web_null') { 0 }
      end

      def null_percentage_web
        stats_cache('null_percentage_web') { 0 }
      end

      def total_booth_valid
        stats_cache('total_booth_valid') { recounts.sum(:total_amount) }
      end

      def valid_percentage_booth
        stats_cache('valid_percentage_booth') do
          total_valid_votes.zero? ? 0 : total_booth_valid * 100 / total_valid_votes.to_f
        end
      end

      def total_booth_white
        stats_cache('total_booth_white') { recounts.sum(:white_amount) }
      end

      def white_percentage_booth
        stats_cache('white_percentage_booth') do
          total_white_votes.zero? ? 0 : total_booth_white * 100 / total_white_votes.to_f
        end
      end

      def total_booth_null
        stats_cache('total_booth_null') { recounts.sum(:null_amount) }
      end

      def null_percentage_booth
        stats_cache('null_percentage_booth') do
          total_null_votes.zero? ? 0 : total_booth_null * 100 / total_null_votes.to_f
        end
      end

      def total_valid_votes
        stats_cache('total_valid_votes') { total_web_valid + total_booth_valid }
      end

      def total_valid_percentage
        stats_cache('total_valid_percentage') do
          total_participants.zero? ? 0 : total_valid_votes * 100 / total_participants.to_f
        end
      end

      def total_white_votes
        stats_cache('total_white_votes') { total_web_white + total_booth_white }
      end

      def total_white_percentage
        stats_cache('total_white_percentage') do
          total_participants.zero? ? 0 : total_white_votes * 100 / total_participants.to_f
        end
      end

      def total_null_votes
        stats_cache('total_null_votes') { total_web_null + total_booth_null }
      end

      def total_null_percentage
        stats_cache('total_null_percentage') do
          total_participants.zero? ? 0 : total_null_votes * 100 / total_participants.to_f
        end
      end

      def voters
        stats_cache('voters') { @poll.voters }
      end

      def recounts
        stats_cache('recounts') { @poll.recounts }
      end

      def stats_cache(key, &block)
        Rails.cache.fetch("polls_stats/#{@poll.id}/#{key}", &block)
      end

  end
end
