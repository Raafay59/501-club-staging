class ChangeDefaultRoleAndSeedAdmin < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :role, "unauthorized"

    execute <<-SQL
      INSERT INTO users (email, role, created_at, updated_at)
      VALUES ('raafay@tamu.edu', 'admin', NOW(), NOW())
      ON CONFLICT (email) DO UPDATE SET role = 'admin';
    SQL

    execute <<-SQL
      INSERT INTO users (email, role, created_at, updated_at)
      VALUES ('501clubtestuser@gmail.com', 'admin', NOW(), NOW())
      ON CONFLICT (email) DO UPDATE SET role = 'admin';
    SQL
  end

  def down
    change_column_default :users, :role, "editor"
  end
end
