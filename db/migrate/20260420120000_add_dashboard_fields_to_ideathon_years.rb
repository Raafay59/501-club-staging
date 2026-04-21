class AddDashboardFieldsToIdeathonYears < ActiveRecord::Migration[8.1]
     def change
          add_column :ideathon_years, :year, :integer unless column_exists?(:ideathon_years, :year)
          add_column :ideathon_years, :theme, :string unless column_exists?(:ideathon_years, :theme)

          add_index :ideathon_years, :year, unique: true unless index_exists?(:ideathon_years, :year)
     end
end
