class CreateJudges < ActiveRecord::Migration[8.0]
  def change
    create_table :judges do |t|
      t.string :judge_name, null: false
      t.string :judge_title, null: false
      t.text :judge_bio, null: false
      t.integer :ideathon, null: false

      t.timestamps
    end
  end
end
