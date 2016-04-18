require 'zip'
class NewsletterZip
  attr_accessor :filename

  def initialize(filename)
    @filename = filename
  end

  def emails
    User.newsletter.pluck(:email).join("\n")
  end

  def path
    Rails.root + "/tmp/#{filename}.zip"
  end

  def create
    Zip::File.open(path, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("#{filename}.txt") do |file|
        file.write emails
      end
    end
  end

end