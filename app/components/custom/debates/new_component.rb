class Debates::NewComponent < ApplicationComponent
    include Header
    attr_reader :debate, :geozones

    def initialize(debate, geozones)
      @geozones = geozones
      @debate = debate
    end

    def title
      t("debates.new.start_new")
    end
  end
