module SendCsvData
  extend ActiveSupport::Concern

  def send_csv_data(resources)
    send_data DownloadSetting.csv_for(resources, params[:downloadable]),
              type: "text/csv",
              disposition: "attachment",
              filename: "#{resources.model_name.plural}.csv"
  end
end
