require 'zip'
class Admin::NewslettersController < Admin::BaseController

  def index
  end

  def users
    folder = Rails.root + "/tmp/"
    zipfile_name = folder + "emails.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("emails.txt") do |os|
        os.write User.newsletter.pluck(:email).join("\n")
      end
    end
    send_file(File.join(folder + "emails.zip"), :type => 'application/zip')
  end

end