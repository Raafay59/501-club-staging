require "csv"

class CsvImporter
     ALLOWED_CONTENT_TYPES = [ "text/csv", "application/csv", "application/vnd.ms-excel", "text/plain" ].freeze

     def initialize(file:, model:, attribute_map:)
          @file = file
          @model = model
          @attribute_map = attribute_map
     end

     def import
          error_message = file_validation_error
          return fatal_result(error_message) if error_message.present?

          results = { success: 0, failed: 0, errors: [] }
          CSV.foreach(@file.path, headers: true).with_index(2) do |row, line_number|
               begin
                    @model.create!(map_attributes(row))
                    results[:success] += 1
               rescue StandardError => e
                    results[:failed] += 1
                    results[:errors] << "Row #{line_number}: #{e.message}"
               end
          end

          ActivityLog.record_import(model: @model, count: results[:success])
          results
     rescue CSV::MalformedCSVError
          fatal_result("Invalid CSV format")
     end

  private

       def fatal_result(error_message)
            { success: 0, failed: 1, errors: [ error_message ] }
       end

       def file_validation_error
            return "No file provided" if @file.nil?
            return "Invalid file type" unless csv_extension?
            return "Invalid file type" unless valid_content_type?
            return "Invalid CSV headers" unless expected_headers_present?

            nil
       end

       def csv_extension?
            File.extname(@file.original_filename.to_s).casecmp(".csv").zero?
       end

       def valid_content_type?
            return true if @file.content_type.blank?

            ALLOWED_CONTENT_TYPES.include?(@file.content_type)
       end

       def expected_headers_present?
            headers =
              begin
                   CSV.open(@file.path, headers: true, return_headers: true) { |csv| csv.first&.headers }
              rescue CSV::MalformedCSVError
                   return false
              end
            normalized_headers = headers&.map { |header| header.to_s.strip }
            return false if normalized_headers.blank?

            expected_headers = @attribute_map.keys.map(&:to_s)
            (expected_headers - normalized_headers).empty?
       end

       def map_attributes(row)
            attributes = {}
            @attribute_map.each do |csv_column, model_column|
                 attributes[model_column] = row[csv_column]
            end
            attributes
       end
end
