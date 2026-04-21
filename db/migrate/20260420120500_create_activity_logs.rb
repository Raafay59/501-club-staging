# frozen_string_literal: true

# Supports fresh installs and Heroku cutover from 501-club-staging where
# `activity_logs` references `users` (`user_id`) instead of `admins`.
class CreateActivityLogs < ActiveRecord::Migration[8.1]
     def up
          if table_exists?(:activity_logs) && column_exists?(:activity_logs, :user_id) && !column_exists?(:activity_logs, :admin_id)
               add_reference :activity_logs, :admin, foreign_key: true, null: true unless column_exists?(:activity_logs, :admin_id)

               execute <<~SQL.squish
        UPDATE activity_logs al
        SET admin_id = a.id
        FROM admins a
        INNER JOIN users u ON lower(trim(a.email)) = lower(trim(u.email))
        WHERE al.user_id = u.id
      SQL

               execute "DELETE FROM activity_logs WHERE admin_id IS NULL"

               remove_reference :activity_logs, :user, foreign_key: true if column_exists?(:activity_logs, :user_id)

               change_column_null :activity_logs, :admin_id, false
          elsif !table_exists?(:activity_logs)
               create_table :activity_logs do |t|
                    t.references :admin, null: false, foreign_key: true
                    t.string :action, null: false
                    t.string :content_type, null: false
                    t.text :item_name, null: false
                    t.text :message, null: false

                    t.timestamps
               end

               add_index :activity_logs, :created_at, order: { created_at: :desc }
               add_index :activity_logs, :content_type
          end
     end

     def down
          raise ActiveRecord::IrreversibleMigration
     end
end
