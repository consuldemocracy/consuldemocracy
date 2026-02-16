class Shared::DownloadCsvLinkComponent < ApplicationComponent
    attr_reader :path_helper, :i18n_key

    def initialize(path_helper:, i18n_key:)
      @path_helper = path_helper
      @i18n_key = i18n_key
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
  