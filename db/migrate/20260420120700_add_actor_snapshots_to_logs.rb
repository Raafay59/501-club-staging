class AddActorSnapshotsToLogs < ActiveRecord::Migration[8.1]
     def up
          add_column :activity_logs, :actor_name, :string unless column_exists?(:activity_logs, :actor_name)
          add_column :activity_logs, :actor_email, :string unless column_exists?(:activity_logs, :actor_email)
          add_column :manager_action_logs, :actor_name, :string unless column_exists?(:manager_action_logs, :actor_name)
          add_column :manager_action_logs, :actor_email, :string unless column_exists?(:manager_action_logs, :actor_email)

          if table_exists?(:activity_logs) && column_exists?(:activity_logs, :admin_id) && table_exists?(:admins)
               execute <<~SQL
                 UPDATE activity_logs
                 SET actor_name = COALESCE(admins.full_name, admins.email),
                     actor_email = admins.email
                 FROM admins
                 WHERE activity_logs.admin_id = admins.id
               SQL
          end

          if table_exists?(:manager_action_logs) && column_exists?(:manager_action_logs, :admin_id) && table_exists?(:admins)
               execute <<~SQL
                 UPDATE manager_action_logs
                 SET actor_name = COALESCE(admins.full_name, admins.email),
                     actor_email = admins.email
                 FROM admins
                 WHERE manager_action_logs.admin_id = admins.id
               SQL
          end

          change_column_null :activity_logs, :admin_id, true if column_exists?(:activity_logs, :admin_id)
          change_column_null :manager_action_logs, :admin_id, true if column_exists?(:manager_action_logs, :admin_id)
     end

     def down
          null_activity_log_count = select_value("SELECT COUNT(*) FROM activity_logs WHERE admin_id IS NULL").to_i
          null_manager_log_count = select_value("SELECT COUNT(*) FROM manager_action_logs WHERE admin_id IS NULL").to_i

          if null_activity_log_count.positive? || null_manager_log_count.positive?
               fallback_admin_id = select_value("SELECT id FROM admins ORDER BY id ASC LIMIT 1")
               if fallback_admin_id.blank?
                    raise ActiveRecord::IrreversibleMigration, "Cannot restore NOT NULL on log admin_id columns without at least one admin record."
               end

               execute <<~SQL
                 UPDATE activity_logs
                 SET admin_id = #{fallback_admin_id}
                 WHERE admin_id IS NULL
               SQL

               execute <<~SQL
                 UPDATE manager_action_logs
                 SET admin_id = #{fallback_admin_id}
                 WHERE admin_id IS NULL
               SQL
          end

          change_column_null :activity_logs, :admin_id, false
          change_column_null :manager_action_logs, :admin_id, false

          remove_column :activity_logs, :actor_name
          remove_column :activity_logs, :actor_email
          remove_column :manager_action_logs, :actor_name
          remove_column :manager_action_logs, :actor_email
     end
end
