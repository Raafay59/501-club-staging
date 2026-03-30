require "csv"

class CsvImporter
    def initialize(file:, model:, attribute_map:, after_create: nil)
        @file = file
        @model = model
        @attribute_map = attribute_map
        @after_create = after_create
    end

    def import
        return { success: 0, failed: 0, errors: [ "No file provided" ] } if @file.nil?
        return { success: 0, failed: 0, errors: [ "Invalid file type" ] } unless valid_file?
        results = { success: 0, failed: 0, errors: [] }
        CSV.foreach(@file.path, headers: true) do |row|
            begin
                record = @model.create!(map_attributes(row))
                @after_create&.call(record)
                results[:success] += 1
            rescue StandardError => e
                results[:failed] += 1
                results[:errors] << e.message
            end
        end
        results
    end

    def valid_file?
        @file.content_type == "text/csv" || File.extname(@file.original_filename) == ".csv"
    end

    private
    def map_attributes(row)
        attributes = {}
        @attribute_map.each do |csv_column, model_column|
            attributes[model_column] = row[csv_column]
        end
        attributes
    end
end
