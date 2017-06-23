class Admin::NewslettersController < Admin::BaseController

  def index
  end

  def users
    zip = NewsletterZip.new('emails')
    zip.create

    File.open(File.join(zip.path), 'r') do |f|
      send_data f.read, type: 'application/zip', filename: "emails.zip"
    end
  end

end