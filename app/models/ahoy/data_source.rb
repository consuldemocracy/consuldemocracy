# This class combines multiple collections with shared keys into a
# hash of collections compatible with C3.js charts
#----------------------------------------------------------------------

module Ahoy
  class DataSource

    # Adds a collection with the datasource
    # Name is the name of the collection and will be showed in the
    # chart
    def add(name, collection)
      collections.push data:  collection, name: name
      collection.each{ |k, v| add_key k }
    end

    def build
      data = { x: [] }
      keys.each do |k|
        # Add the key with a valid date format
        data[:x].push k.strftime("%Y-%m-%d")

        # Add the value for each column, or 0 if not present
        collections.each do |col|
          data[col[:name]] ||= []
          count = col[:data][k] || 0
          data[col[:name]].push count
        end
      end

      data
    end

    private

    def collections
      @collections ||= []
    end

    def keys
      @keys ||= []
    end

    def add_key(key)
      keys.push(key) unless keys.include? key
    end

  end

end
