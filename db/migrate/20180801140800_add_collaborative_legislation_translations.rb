class AddCollaborativeLegislationTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :legislation_process_translations do |t|
      t.integer :legislation_process_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :summary
      t.text :description
      t.text :additional_info

      t.index :legislation_process_id, name: "index_199e5fed0aca73302243f6a1fca885ce10cdbb55"
      t.index :locale
    end

    create_table :legislation_question_translations do |t|
      t.integer :legislation_question_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.text :title

      t.index :legislation_question_id, name: "index_d34cc1e1fe6d5162210c41ce56533c5afabcdbd3"
      t.index :locale
    end

    create_table :legislation_draft_version_translations do |t|
      t.integer :legislation_draft_version_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :changelog
      t.text :body
      t.text :body_html
      t.text :toc_html

      t.index :legislation_draft_version_id, name: "index_900e5ba94457606e69e89193db426e8ddff809bc"
      t.index :locale
    end

    create_table :legislation_question_option_translations do |t|
      t.integer :legislation_question_option_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :value

      t.index :legislation_question_option_id, name: "index_61bcec8729110b7f8e1e9e5ce08780878597a209"
      t.index :locale
    end
  end
end
