class AddVideoUrlToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :video_url, :string
  end
end
