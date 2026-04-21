require 'rails_helper'

RSpec.describe "Ideathons", type: :request do
  let!(:admin) { User.create!(email: 'admin@example.com', role: 'admin') }
  let!(:editor) { User.create!(email: 'editor@example.com', role: 'editor') }

  before { login_as(admin) }

  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Innovation') }

  describe "GET /ideathons" do
    it "returns a successful response" do
      get ideathons_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /ideathons/:year" do
    it "returns a successful response" do
      get ideathon_path(ideathon)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /ideathons/:year/overview" do
    it "returns a successful response" do
      get overview_ideathon_path(ideathon)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ideathon 2025 — Overview")
    end

    it "redirects with an alert when year is invalid" do
      get overview_ideathon_path(9999)

      expect(response).to redirect_to(ideathons_path)
      expect(flash[:alert]).to eq("Ideathon year 9999 was not found.")
    end

    context "as an editor" do
      before { login_as(editor) }

      it "allows organizers (editors) to view the overview" do
        get overview_ideathon_path(ideathon)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as an unauthorized user" do
      let(:unauthorized_user) { User.create!(email: "pending@example.com", role: "unauthorized") }

      before { login_as(unauthorized_user) }

      it "redirects away from the app" do
        get overview_ideathon_path(ideathon)
        expect(response).to redirect_to(unauthorized_path)
      end
    end
  end

  describe "GET /ideathons/new" do
    it "returns a successful response" do
      get new_ideathon_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /ideathons" do
    context "with valid parameters" do
      it "creates a new ideathon and redirects" do
        expect {
          post ideathons_path, params: { ideathon: { year: 2026, theme: 'AI' } }
        }.to change(Ideathon, :count).by(1)
        expect(response).to redirect_to(ideathons_path)
      end
    end

    context "with invalid parameters" do
      it "does not create and re-renders the form" do
        expect {
          post ideathons_path, params: { ideathon: { year: nil, theme: '' } }
        }.not_to change(Ideathon, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /ideathons/:year/edit" do
    it "returns a successful response" do
      get edit_ideathon_path(ideathon)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /ideathons/:year" do
    context "with valid parameters" do
      it "updates the ideathon and redirects" do
        patch ideathon_path(ideathon), params: { ideathon: { theme: 'Updated Theme' } }
        ideathon.reload
        expect(ideathon.theme).to eq('Updated Theme')
        expect(response).to redirect_to(ideathons_path)
      end
    end

    context "with empty theme" do
      it "still updates successfully since theme is optional" do
        patch ideathon_path(ideathon), params: { ideathon: { theme: '' } }
        ideathon.reload
        expect(ideathon.theme).to eq('')
        expect(response).to redirect_to(ideathons_path)
      end
    end

    context "when update fails" do
      it "re-renders edit with unprocessable status" do
        allow_any_instance_of(Ideathon).to receive(:update).and_return(false)

        patch ideathon_path(ideathon), params: { ideathon: { theme: 'Will Not Save' } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /ideathons/:year/delete" do
    it "returns a successful response" do
      get delete_ideathon_path(ideathon)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /ideathons/:year" do
    it "deletes the ideathon and redirects" do
      expect {
        delete ideathon_path(ideathon)
      }.to change(Ideathon, :count).by(-1)
      expect(response).to redirect_to(ideathons_path)
    end

    context "as a non-admin editor" do
      before { login_as(editor) }

      it "redirects non-admin users" do
        delete ideathon_path(ideathon)
        expect(response).to redirect_to(ideathons_path)
      end
    end
  end

  describe "POST /ideathons/import" do
    it "imports from a valid CSV file" do
      file = fixture_file_upload('ideathons_import.csv', 'text/csv')

      expect {
        post import_ideathons_path, params: { file: file }
      }.to change(Ideathon, :count).by(2)

      expect(response).to redirect_to(ideathons_path)
    end

    it "rejects non-csv files" do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')

      expect {
        post import_ideathons_path, params: { file: file }
      }.not_to change(Ideathon, :count)

      expect(response).to redirect_to(ideathons_path)
      expect(flash[:alert]).to include('Invalid file type')
    end
  end
end
