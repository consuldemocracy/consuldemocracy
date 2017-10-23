class Poll
  class Stats
    include StatsHelper

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
        stats_cache('total_participants_web_percentage') { calculate_percentage(total_participants_web, total_participants) }
      end

      def total_participants_booth
        stats_cache('total_participants_booth') { recounts.sum(:total_amount) }
      end

      def total_participants_booth_percentage
        stats_cache('total_participants_booth_percentage') { calculate_percentage(total_participants_booth, total_participants) }
      end

      def total_web_valid
        stats_cache('total_web_valid') { voters.where(origin: 'web').count - total_web_white_en_blanco }
      end

      def valid_percentage_web
        stats_cache('valid_percentage_web') { calculate_percentage(total_web_valid, total_valid_votes) }
      end

      def total_web_white
        stats_cache('total_web_white') { total_web_white_en_blanco + total_web_white_by_omission }
      end

      def total_web_white_en_blanco
        stats_cache('total_web_white_en_blanco') do
          @poll.questions.inject(0) do |total, question|
            # Hardcoded Stuff for Madrid 11 Polls where there are only 2 Questions per Poll
            # FIXME: Implement the "Blank Answers" feature at Consul
            total + Poll::Answer.where(question: question, answer: 'En blanco').count
          end
        end
      end

      def total_web_white_by_omission
        stats_cache('total_web_white_by_omission') do
          @poll.questions.inject(0) do |total, question|
            # Hardcoded Stuff for Madrid 11 Polls where there are only 2 Questions per Poll
            # FIXME: Implement the "Blank Answers" feature at Consul
            total + question.blank_by_omission_votes
          end
        end
      end

      def white_percentage_web
        stats_cache('white_percentage_web') { calculate_percentage(total_web_white, total_web_valid) }
      end

      def total_web_null
        stats_cache('total_web_null') { 0 }
      end

      def null_percentage_web
        stats_cache('null_percentage_web') { calculate_percentage(total_web_null, total_web_valid) }
      end

      def total_booth_valid
        stats_cache('total_booth_valid') { total_participants_booth - total_booth_white - total_booth_null }
      end

      def valid_percentage_booth
        stats_cache('valid_percentage_booth') { calculate_percentage(total_booth_valid, total_valid_votes) }
      end

      def total_booth_white
        stats_cache('total_booth_white') { recounts.sum(:white_amount) }
      end

      def white_percentage_booth
        stats_cache('white_percentage_booth') { calculate_percentage(total_booth_white, total_white_votes) }
      end

      def total_booth_null
        stats_cache('total_booth_null') { recounts.sum(:null_amount) }
      end

      def null_percentage_booth
        stats_cache('null_percentage_booth') { calculate_percentage(total_booth_null, total_null_votes) }
      end

      def total_valid_votes
        stats_cache('total_valid_votes') { total_web_valid + total_booth_valid }
      end

      def total_valid_percentage
        stats_cache('total_valid_percentage'){ calculate_percentage(total_valid_votes, total_participants) }
      end

      def total_white_votes
        stats_cache('total_white_votes') { total_web_white + total_booth_white }
      end

      def total_white_percentage
        stats_cache('total_white_percentage') { calculate_percentage(total_white_votes, total_participants) }
      end

      def total_null_votes
        stats_cache('total_null_votes') { total_web_null + total_booth_null }
      end

      def total_null_percentage
        stats_cache('total_null_percentage') { calculate_percentage(total_null_votes, total_participants) }
      end

      def voters
        stats_cache('voters') { @poll.voters }
      end

      def recounts
        stats_cache('recounts') { @poll.recounts }
      end

      def stats_cache(key, &block)
        Rails.cache.fetch("polls_stats/#{@poll.id}/#{key}/v2", &block)
      end

  end
end
