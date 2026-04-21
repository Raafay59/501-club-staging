# frozen_string_literal: true

# When replacing 501-club-staging on Heroku, `users` already exists while `admins`
# was just created by Devise. Copy OAuth-capable rows so later log migrations can
# resolve admin_id from email.
class ImportAdminsFromLegacyUsers < ActiveRecord::Migration[8.1]
     def up
          return unless table_exists?(:users) && table_exists?(:admins)

          execute <<~SQL.squish
      INSERT INTO admins (email, full_name, uid, avatar_url, created_at, updated_at)
      SELECT u.email,
             COALESCE(NULLIF(TRIM(u.name), ''), split_part(lower(trim(u.email)), '@', 1)),
             u.uid,
             NULL,
             u.created_at,
             u.updated_at
      FROM users u
      WHERE NOT EXISTS (
        SELECT 1 FROM admins a WHERE lower(trim(a.email)) = lower(trim(u.email))
      )
    SQL
     end

     def down
          raise ActiveRecord::IrreversibleMigration
     end
end
