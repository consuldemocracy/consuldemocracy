class AddHiddenAtToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :hidden_at, :datetime
  end
end
