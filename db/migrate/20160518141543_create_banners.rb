class CreateBanners < ActiveRecord::Migration[4.2]
  def change
    create_table :banners do |t|
      t.string   :title,  limit: 80
      t.string   :description
      t.string   :target_url
      t.string   :style
      t.string   :image
      t.date     :post_started_at
      t.date     :post_ended_at
      t.datetime :hidden_at

      t.timestamps null: false
    end

    add_index :banners, :hidden_at
  end
end
