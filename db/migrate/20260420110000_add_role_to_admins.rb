class AddRoleToAdmins < ActiveRecord::Migration[8.1]
     def up
          return if column_exists?(:admins, :role)

          add_column :admins, :role, :string, null: false, default: "admin"
          add_index :admins, :role unless index_exists?(:admins, :role)
     end

     def down
          remove_index :admins, :role if index_exists?(:admins, :role)
          remove_column :admins, :role if column_exists?(:admins, :role)
     end
end
