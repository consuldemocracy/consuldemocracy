class Admin::NewslettersController < Admin::BaseController

  def index
  end

  def users
    zip = NewsletterZip.new('emails')
    zip.create
    response.headers["X-Sendfile"] = nil
    send_file(File.join(zip.path), type: 'application/zip')
  end

end