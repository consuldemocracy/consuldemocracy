class Shared::DownloadCsvLinkComponent < ApplicationComponent
    attr_reader :path_helper

    def initialize(path_helper:)
      @path_helper = path_helper
    end

    private
  
    def csv_params
      params
        .to_unsafe_h
        .symbolize_keys
        .merge(format: :csv)
        .except(:page)
    end
  
    def csv_path
      send(path_helper, csv_params)
    end
  end
  