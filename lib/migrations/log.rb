module Migrations::Log

  def log(message)
    print message unless Rails.env.test?
  end

end
