class Banner::Section < ApplicationRecord
  belongs_to :banner
  belongs_to :web_section
end
