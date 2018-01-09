class Banner::Section < ActiveRecord::Base
  enum sections: { homepage: 0, debates: 1, proposals: 2, budgets: 3, more_info: 4 }

  belongs_to :banner
end
