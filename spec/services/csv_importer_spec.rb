require 'rails_helper'

RSpec.describe CsvImporter, type: :service do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  describe 'importing mentors_judges CSV' do
    let(:file) { fixture_file_upload('mentors_judges.csv', 'text/csv') }
    let(:importer) do
      CsvImporter.new(
        file: file,
        model: MentorsJudge,
        attribute_map: {
          "year" => :year,
          "name" => :name,
          "photo_url" => :photo_url,
          "bio" => :bio,
          "is_judge" => :is_judge
        }
      )
    end

    it 'imports valid CSV data successfully' do
      expect { importer.import }.to change(MentorsJudge, :count).by(2)
    end

    it 'returns correct results hash' do
      results = importer.import
      expect(results[:success]).to eq(2)
      expect(results[:failed]).to eq(0)
      expect(results[:errors]).to be_empty
    end
  end

  describe 'importing faqs CSV' do
    let(:file) { fixture_file_upload('faqs.csv', 'text/csv') }
    let(:importer) do
      CsvImporter.new(
        file: file,
        model: Faq,
        attribute_map: {
          "year" => :year,
          "question" => :question,
          "answer" => :answer
        }
      )
    end

    it 'imports valid CSV data successfully' do
      expect { importer.import }.to change(Faq, :count).by(2)
    end
  end

  describe 'error handling' do
    it 'returns error when no file provided' do
      importer = CsvImporter.new(file: nil, model: MentorsJudge, attribute_map: {})
      result = importer.import
      expect(result[:errors]).to include('No file provided')
    end

    it 'returns error for invalid file type' do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: { "name" => :name })
      result = importer.import
      expect(result[:errors]).to include('Invalid file type')
    end
  end

  describe '#valid_file?' do
    it 'returns true for CSV content type' do
      file = fixture_file_upload('mentors_judges.csv', 'text/csv')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: {})
      expect(importer.valid_file?).to be true
    end
  end
end
