class AddCommentsCountToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :comments_count, :integer
  end
end
