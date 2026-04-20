require 'rails_helper'

RSpec.describe CsvImporter, type: :service do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }
  let(:default_attribute_map) do
    {
      "year" => :year,
      "name" => :name,
      "photo_url" => :photo_url,
      "bio" => :bio,
      "is_judge" => :is_judge
    }
  end

  after do
    Array(@uploaded_csv_tempfiles).each(&:close!)
  end

  def uploaded_csv(filename:, body:, content_type: 'text/csv')
    tempfile = Tempfile.new([ File.basename(filename, '.csv'), '.csv' ])
    tempfile.write(body)
    tempfile.rewind
    @uploaded_csv_tempfiles ||= []
    @uploaded_csv_tempfiles << tempfile
    ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: filename, type: content_type)
  end

  describe 'importing mentors_judges CSV' do
    let(:file) { fixture_file_upload('mentors_judges.csv', 'text/csv') }
    let(:importer) do
      CsvImporter.new(
        file: file,
        model: MentorsJudge,
        attribute_map: default_attribute_map
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
      expect(result[:failed]).to eq(1)
      expect(result[:errors]).to include('No file provided')
    end

    it 'returns error for invalid file type' do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: default_attribute_map)
      result = importer.import
      expect(result[:errors]).to include('Invalid file type')
      expect(result[:failed]).to eq(1)
      expect(result[:success]).to eq(0)
    end

    it 'returns error for csv files with incorrect headers' do
      file = fixture_file_upload('mentors_judges.csv', 'text/csv')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: { "full_name" => :name })
      result = importer.import

      expect(result[:errors]).to include('Invalid CSV headers')
      expect(result[:failed]).to eq(1)
      expect(result[:success]).to eq(0)
    end

    it 'tracks failed rows when a row cannot be persisted' do
      file = uploaded_csv(
        filename: 'mentors_bad_row.csv',
        body: "year,name,photo_url,bio,is_judge\n9999,Broken Row,https://img.test/a.jpg,Bio,true\n"
      )
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: default_attribute_map)

      result = importer.import

      expect(result[:success]).to eq(0)
      expect(result[:failed]).to eq(1)
      expect(result[:errors].first).to include('Couldn\'t find Ideathon')
    end

    it 'returns invalid CSV format for malformed bodies discovered during iteration' do
      file = uploaded_csv(
        filename: 'mentors_malformed.csv',
        body: "year,name,photo_url,bio,is_judge\n2025,Good,https://img.test/a.jpg,Bio,true\n\"unterminated"
      )
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: default_attribute_map)

      result = importer.import

      expect(result).to eq(success: 0, failed: 1, errors: [ 'Invalid CSV format' ])
    end
  end

  describe '#valid_file?' do
    it 'returns true for CSV content type' do
      file = fixture_file_upload('mentors_judges.csv', 'text/csv')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: default_attribute_map)
      expect(importer.valid_file?).to be true
    end

    it 'returns false for non-csv extension' do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: default_attribute_map)
      expect(importer.valid_file?).to be false
    end

    it 'returns false when expected headers are missing' do
      file = fixture_file_upload('mentors_judges.csv', 'text/csv')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: { "full_name" => :name })
      expect(importer.valid_file?).to be false
    end

    it 'returns false for malformed CSV headers' do
      file = uploaded_csv(filename: 'broken_headers.csv', body: '"unterminated header')
      importer = CsvImporter.new(file: file, model: MentorsJudge, attribute_map: default_attribute_map)

      expect(importer.valid_file?).to be false
    end
  end
end
