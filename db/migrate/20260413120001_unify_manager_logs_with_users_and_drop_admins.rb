# frozen_string_literal: true

class UnifyManagerLogsWithUsersAndDropAdmins < ActiveRecord::Migration[8.0]
  def up
    add_reference :manager_action_logs, :user, foreign_key: true, null: true

    execute <<~SQL.squish
      UPDATE manager_action_logs mal
      SET user_id = u.id
      FROM admins a
      INNER JOIN users u ON LOWER(TRIM(a.email)) = LOWER(TRIM(u.email))
      WHERE mal.admin_id = a.id
    SQL

    execute "DELETE FROM manager_action_logs WHERE user_id IS NULL"

    remove_reference :manager_action_logs, :admin, foreign_key: true

    change_column_null :manager_action_logs, :user_id, false

    drop_table :admins, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
