require 'rails_helper'

RSpec.describe "JudgesImport", type: :request do
    describe "POST /judges/import" do
        let(:file) do
            it "imports judges from a valid CSV file" do
                file = fixture_file_upload(
                    Rails.root.join("spec/fixtures/files/judges.csv"),
                    "text/csv"
                )
            expect {
                post import_judges_path, params: { file: file }
            }.to change(Judge, :count).by_at_least(1)
            expect(response).to redirect_to(judges_path)
            follow_redirect!
            expect(response.body).to include("Judges imported successfully")
            end
        end
    end

    it "does not import when no CSV file is provided" do
        expect {
            post import_judges_path, params: { file: nil }
        }.not_to change(Judge, :count)
    end

    it "rejects non-CSV files" do
        file = fixture_file_upload(
            Rails.root.join("spec/fixtures/files/not_a_csv.txt"),
            "text/plain"
        )
        expect {
            post import_judges_path, params: { file: file }
        }.not_to change(Judge, :count)
    end

    it "handles invalid CSV data gracefully" do
        file = fixture_file_upload(
            Rails.root.join("spec/fixtures/files/invalid_judges.csv"),
            "text/csv"
        )
        expect {
            post import_judges_path, params: { file: file }
    }.to change(Judge, :count).by(1)
        expect(response).to redirect_to(judges_path)
        follow_redirect!
        expect(response.body).to include("Some judges were not imported")
    end
end
