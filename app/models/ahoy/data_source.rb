# This class combines multiple collections with shared keys into a
# hash of collections compatible with C3.js charts
#----------------------------------------------------------------------

module Ahoy
  class DataSource
    def self.build(&block)
      new.tap { |data_source| block.call(data_source) }.build
    end

    # Adds a collection with the datasource
    # Name is the name of the collection and will be showed in the
    # chart
    def add(name, collection)
      collections.push data: collection, name: name
      dates.merge(collection.keys)
    end

    def build
      data = { x: [] }
      dates.each do |date|
        # Add the key with a valid date format
        data[:x].push date.strftime("%Y-%m-%d")

        # Add the value for each column, or 0 if not present
        collections.each do |col|
          data[col[:name]] ||= []
          count = col[:data][date] || 0
          data[col[:name]].push count
        end
      end

      data
    end

    private

      def collections
        @collections ||= []
      end

      def dates
        @dates ||= Set.new
      end
  end
end
