class CreateWidgetFeeds < ActiveRecord::Migration
  def change
    create_table :widget_feeds do |t|
      t.string :kind
      t.timestamps null: false
    end
  end
end
