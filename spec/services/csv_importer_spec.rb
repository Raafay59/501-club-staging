require "rails_helper"
require "tempfile"

RSpec.describe CsvImporter do
     def build_upload(filename:, content:, content_type: "text/csv")
          file = Tempfile.new([ File.basename(filename, ".*"), File.extname(filename) ])
          file.write(content)
          file.rewind
          Rack::Test::UploadedFile.new(file.path, content_type, original_filename: filename)
     end

     describe "#import" do
          let(:model) { Ideathon }
          let(:attribute_map) { { "year" => :year, "name" => :name } }

          it "returns fatal error when file is missing" do
               result = described_class.new(file: nil, model: model, attribute_map: attribute_map).import
               expect(result[:errors]).to include("No file provided")
          end

          it "rejects non-csv extension" do
               upload = build_upload(filename: "bad.txt", content: "year,name\n2026,Ideathon 2026\n")
               result = described_class.new(file: upload, model: model, attribute_map: attribute_map).import
               expect(result[:errors]).to include("Invalid file type")
          end

          it "rejects missing required headers" do
               upload = build_upload(filename: "missing.csv", content: "year,theme\n2026,Build\n")
               result = described_class.new(file: upload, model: model, attribute_map: attribute_map).import
               expect(result[:errors]).to include("Invalid CSV headers")
          end

          it "imports valid rows and reports row-level failures" do
               Ideathon.create!(year: 2026, name: "Existing")
               upload = build_upload(
                 filename: "ideathons.csv",
                 content: "year,name\n2027,Ideathon 2027\n2026,Duplicate year\n"
               )

               result = described_class.new(file: upload, model: model, attribute_map: attribute_map).import
               expect(result[:success]).to eq(1)
               expect(result[:failed]).to eq(1)
               expect(result[:errors].first).to match(/\ARow 3:/)
               expect(Ideathon.find_by(year: 2027)).to be_present
          end
     end
end
