class CreateActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.text :message, null: false

      t.timestamps
    end

    add_index :activity_logs, :created_at, order: { created_at: :desc }
  end
end
