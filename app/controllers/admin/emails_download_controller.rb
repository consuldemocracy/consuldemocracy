class Admin::EmailsDownloadController < Admin::BaseController
  def index
  end

  def generate_csv
    users_segment = params[:users_segment]
    filename = t("admin.segment_recipient.#{users_segment}")

    csv_file = users_segment_emails_csv(users_segment)
    send_data csv_file, filename: "#{filename}.csv"
  end

  private

  def users_segment_emails_csv(users_segment)
    UserSegments.user_segment_emails(users_segment).join(',')
  end
end
