require 'zip'
class Admin::NewslettersController < Admin::BaseController

  def index
  end

  def users
    folder = Rails.root + "/tmp/"
    zipfile_name = folder + "emails.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("emails.txt") { |os| os.write 'peter@example.com' }
    end
    send_file(File.join(folder + "emails.zip"), :type => 'application/zip')
  end

end