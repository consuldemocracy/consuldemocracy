class AddVideoUrlToProposal < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :video_url, :string
  end
end
