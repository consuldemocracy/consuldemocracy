load Rails.root.join("app", "models", "image.rb")

class Image < ApplicationRecord

  def self.styles
    {
      larger: { resize: "1920x" },
      large: { resize: "x#{Setting["uploads.images.min_height"]}" },
      medium: { gravity: "center", resize: "300x300^", crop: "300x300+0+0" },
      thumb: { gravity: "center", resize: "140x245^", crop: "140x245+0+0" }
    }
  end

end
