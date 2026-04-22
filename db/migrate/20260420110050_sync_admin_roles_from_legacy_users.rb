# frozen_string_literal: true

# After `role` exists on `admins`, align roles with legacy `users.role` when present.
class SyncAdminRolesFromLegacyUsers < ActiveRecord::Migration[8.1]
     def up
          return unless table_exists?(:users) && table_exists?(:admins)
          return unless column_exists?(:admins, :role)

          execute <<~SQL.squish
      UPDATE admins AS a
      SET role = CASE trim(u.role)
        WHEN 'admin' THEN 'admin'
        WHEN 'editor' THEN 'editor'
        ELSE 'unauthorized'
      END
      FROM users u
      WHERE lower(trim(a.email)) = lower(trim(u.email))
    SQL
     end

     def down
          raise ActiveRecord::IrreversibleMigration
     end
end
