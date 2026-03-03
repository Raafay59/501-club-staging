require 'rails_helper'

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
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
