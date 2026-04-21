# frozen_string_literal: true

# Supports fresh installs and Heroku cutover from 501-club-staging where
# `manager_action_logs` references `users` (`user_id`) instead of `admins`.
class CreateManagerActionLogs < ActiveRecord::Migration[8.1]
     def up
          if table_exists?(:manager_action_logs) && column_exists?(:manager_action_logs, :user_id) && !column_exists?(:manager_action_logs, :admin_id)
               add_reference :manager_action_logs, :admin, foreign_key: true, null: true unless column_exists?(:manager_action_logs, :admin_id)

               execute <<~SQL.squish
        UPDATE manager_action_logs mal
        SET admin_id = a.id
        FROM admins a
        INNER JOIN users u ON lower(trim(a.email)) = lower(trim(u.email))
        WHERE mal.user_id = u.id
      SQL

               execute "DELETE FROM manager_action_logs WHERE admin_id IS NULL"

               remove_reference :manager_action_logs, :user, foreign_key: true if column_exists?(:manager_action_logs, :user_id)

               change_column_null :manager_action_logs, :admin_id, false
          elsif !table_exists?(:manager_action_logs)
               create_table :manager_action_logs do |t|
                    t.references :admin, null: false, foreign_key: true
                    t.string :action, null: false
                    t.string :record_type
                    t.bigint :record_id
                    t.jsonb :metadata, null: false, default: {}
                    t.string :ip_address
                    t.string :user_agent

                    t.timestamps
               end

               add_index :manager_action_logs, %i[record_type record_id]
               add_index :manager_action_logs, :action
               add_index :manager_action_logs, :created_at
          end
     end

     def down
          raise ActiveRecord::IrreversibleMigration
     end
end
