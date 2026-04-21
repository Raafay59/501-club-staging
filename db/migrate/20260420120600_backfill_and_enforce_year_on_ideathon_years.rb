class BackfillAndEnforceYearOnIdeathonYears < ActiveRecord::Migration[8.1]
     def up
          return unless table_exists?(:ideathon_years) && column_exists?(:ideathon_years, :year)

          execute <<~SQL
            UPDATE ideathon_years
            SET year = CAST(substring(name FROM '(19|20)\\d{2}') AS integer)
            WHERE year IS NULL
              AND name ~ '(19|20)\\d{2}';
          SQL

          execute <<~SQL
            UPDATE ideathon_years
            SET year = EXTRACT(YEAR FROM start_date)::integer
            WHERE year IS NULL
              AND start_date IS NOT NULL;
          SQL

          execute <<~SQL
            UPDATE ideathon_years
            SET year = EXTRACT(YEAR FROM created_at)::integer
            WHERE year IS NULL
              AND created_at IS NOT NULL;
          SQL

          col = connection.columns(:ideathon_years).find { |c| c.name == "year" }
          return if col.nil? || col.null == false

          change_column_null :ideathon_years, :year, false
     end

     def down
          change_column_null :ideathon_years, :year, true
     end
end
