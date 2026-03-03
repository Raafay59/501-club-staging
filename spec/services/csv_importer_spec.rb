require 'rails_helper'
RSpec.describe CsvImporter, type: :service do
    let(:file) do
        fixture_file_upload('/judges.csv', 'text/csv')
    end

    let(:importer) do
        CsvImporter.new(
            file: file,
            model: Judge,
            attribute_map: {
                "Name" => :judge_name,
                "Title" => :judge_title,
                "Bio" => :judge_bio,
                "Ideathon" => :ideathon
            }
        )
    end

    it "imports valid CSV data successfully" do
        expect {
            importer.import
        }.to change(Judge, :count).by_at_least(1)
    end

    it "returns correct results hash" do
        results = importer.import
        expect(results[:success]).to be >= 1
        expect(results[:failed]).to eq(0)
        expect(results[:errors]).to be_empty
    end
end
