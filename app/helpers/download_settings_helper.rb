module DownloadSettingsHelper
  def send_csv_data(resources)
    attributes = params[:downloadable].presence || resources.get_downloadables_names

    send_data resources.to_csv(attributes),
              type: "text/csv",
              disposition: "attachment",
              filename: "#{resources.model_name.plural}.csv"
  end
end
