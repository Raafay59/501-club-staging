class SeedTestAdmin < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      INSERT INTO users (email, role, created_at, updated_at)
      VALUES ('501clubtestuser@gmail.com', 'admin', NOW(), NOW())
      ON CONFLICT (email) DO UPDATE SET role = 'admin';
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM users WHERE email = '501clubtestuser@gmail.com';
    SQL
  end
end
