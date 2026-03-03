class SetupUsersForOauth < ActiveRecord::Migration[8.0]
  def up
    drop_table :users if ActiveRecord::Base.connection.table_exists?(:users)
    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :uid
      t.string :provider
      t.string :role, null: false, default: "editor"
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, [ :uid, :provider ], unique: true
  end

  def down
    drop_table :users
  end
end
