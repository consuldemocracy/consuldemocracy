module FactoryBot
  module Strategy
    class Insert
      def initialize
        @strategy = FactoryBot.strategy_by_name(:attributes_for).new
      end

      delegate :association, to: :@strategy

      def result(evaluation)
        build_class = evaluation.instance_variable_get(:@attribute_assigner)
                                .instance_variable_get(:@build_class)

        timestamps = { created_at: Time.current, updated_at: Time.current }.select do |attribute, _|
          build_class.has_attribute?(attribute)
        end

        build_class.insert!(timestamps.merge(@strategy.result(evaluation)))
      end
    end

    FactoryBot.register_strategy(:insert, Insert)
  end
end
