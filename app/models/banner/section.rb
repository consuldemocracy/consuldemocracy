class Banner::Section < ActiveRecord::Base
  belongs_to :banner
  belongs_to :web_section
end
