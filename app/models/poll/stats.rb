class Poll
  class Stats

    def initialize(poll)
      @poll = poll
    end

    def generate
      stats = %w[total_participants total_participants_web total_participants_booth]
      stats.map { |stat_name| [stat_name.to_sym, send(stat_name)] }.to_h
    end

    private

      def total_participants
        stats_cache('total_participants') { voters.uniq.count }
      end

      def total_participants_web
        stats_cache('total_participants_web') { voters.where(origin: 'web').count }
      end

      def total_participants_booth
        stats_cache('total_participants_booth') { voters.where(origin: 'booth').count }
      end

      def voters
        stats_cache('voters') { @poll.voters }
      end

      def stats_cache(key, &block)
        Rails.cache.fetch("polls_stats/#{@poll.id}/#{key}/v7", &block)
      end

  end
end