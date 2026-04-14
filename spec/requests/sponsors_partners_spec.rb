require 'rails_helper'
require 'csv'

RSpec.describe "SponsorsPartners", type: :request do
  let!(:admin) { User.create!(email: 'admin@example.com', role: 'admin') }
  let!(:editor) { User.create!(email: 'editor@example.com', role: 'editor') }
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  before { login_as(admin) }

  let!(:sponsors_partner) { SponsorsPartner.create!(year: 2025, name: 'Acme Corp', is_sponsor: true) }

  let(:valid_attributes) { { year: 2025, name: 'BigCo', blurb: 'Great company', is_sponsor: false } }
  let(:invalid_attributes) { { year: nil, name: nil } }

  describe "GET /sponsors_partners" do
    it "returns a successful response" do
      get sponsors_partners_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /sponsors_partners/:id" do
    it "returns a successful response" do
      get sponsors_partner_path(sponsors_partner)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /sponsors_partners/new" do
    it "returns a successful response" do
      get new_sponsors_partner_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /sponsors_partners" do
    context "with valid parameters" do
      it "creates a new sponsor/partner and redirects" do
        expect {
          post sponsors_partners_path, params: { sponsors_partner: valid_attributes }
        }.to change(SponsorsPartner, :count).by(1)
        expect(response).to redirect_to(sponsors_partners_path)
      end
    end

    context "with invalid parameters" do
      it "does not create and re-renders the form" do
        expect {
          post sponsors_partners_path, params: { sponsors_partner: invalid_attributes }
        }.not_to change(SponsorsPartner, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /sponsors_partners/:id/edit" do
    it "returns a successful response" do
      get edit_sponsors_partner_path(sponsors_partner)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /sponsors_partners/:id" do
    context "with valid parameters" do
      it "updates and redirects" do
        patch sponsors_partner_path(sponsors_partner), params: { sponsors_partner: { name: 'Updated Corp' } }
        sponsors_partner.reload
        expect(sponsors_partner.name).to eq('Updated Corp')
        expect(response).to redirect_to(sponsors_partners_path)
      end
    end

    context "with invalid parameters" do
      it "does not update and re-renders the form" do
        patch sponsors_partner_path(sponsors_partner), params: { sponsors_partner: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /sponsors_partners/:id/delete" do
    it "returns a successful response" do
      get delete_sponsors_partner_path(sponsors_partner)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /sponsors_partners/:id" do
    it "deletes and redirects" do
      expect {
        delete sponsors_partner_path(sponsors_partner)
      }.to change(SponsorsPartner, :count).by(-1)
      expect(response).to redirect_to(sponsors_partners_path)
    end

    context "as a non-admin editor" do
      before { login_as(editor) }

      it "redirects non-admin users" do
        delete sponsors_partner_path(sponsors_partner)
        expect(response).to redirect_to(ideathons_path)
      end
    end
  end

  describe "POST /sponsors_partners/import" do
    it "imports from a valid CSV file" do
      file = fixture_file_upload('sponsors_partners.csv', 'text/csv')

      expect {
        post import_sponsors_partners_path, params: { file: file }
      }.to change(SponsorsPartner, :count).by(2)

      expect(response).to redirect_to(sponsors_partners_path)
    end

    it "rejects non-csv files" do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')

      expect {
        post import_sponsors_partners_path, params: { file: file }
      }.not_to change(SponsorsPartner, :count)

      expect(response).to redirect_to(sponsors_partners_path)
      expect(flash[:alert]).to include('Invalid file type')
    end
  end

  describe "GET /sponsors_partners/export" do
    it "exports current-year sponsors as CSV" do
      Ideathon.create!(year: 2026, theme: 'Future')
      SponsorsPartner.create!(year: 2026, name: 'Future Corp', job_title: 'Head of Partnerships', logo_url: 'https://logo.test/future.png', blurb: 'Future sponsor', is_sponsor: true)
      SponsorsPartner.create!(year: 2026, name: 'Future Partner', logo_url: 'https://logo.test/partner.png', blurb: 'Not a sponsor', is_sponsor: false)

      get export_sponsors_partners_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/csv')
      expect(response.headers['Content-Disposition']).to include('attachment;')

      rows = CSV.parse(response.body, headers: true)
      expect(rows.headers).to eq([ 'Sponsor name', 'Logo URL', 'Job title', 'Bio' ])
      expect(rows.length).to eq(1)
      expect(rows.map { |row| row['Sponsor name'] }).to contain_exactly('Future Corp')
      expect(rows[0]['Job title']).to eq('Head of Partnerships')
      expect(rows.map { |row| row['Sponsor name'] }).not_to include('Acme Corp')
      expect(rows.map { |row| row['Sponsor name'] }).not_to include('Future Partner')
    end

    it "redirects with an alert when no sponsors exist in current year" do
      Ideathon.create!(year: 2026, theme: 'Future')

      get export_sponsors_partners_path(format: :csv)

      expect(response).to redirect_to(sponsors_partners_path)
      expect(flash[:alert]).to eq('No sponsors to export')
    end

    it "redirects non-admin users" do
      login_as(editor)

      get export_sponsors_partners_path(format: :csv)

      expect(response).to redirect_to(ideathons_path)
    end

    it "redirects unauthenticated users to login" do
      login_as(nil)

      get export_sponsors_partners_path(format: :csv)

      expect(response).to redirect_to(login_path)
    end

    it "redirects with an error when export fails" do
      allow(CSV).to receive(:generate).and_raise(StandardError, 'boom')

      get export_sponsors_partners_path(format: :csv)

      expect(response).to redirect_to(sponsors_partners_path)
      expect(flash[:alert]).to eq('Export failed. Please try again.')
    end
  end
end
