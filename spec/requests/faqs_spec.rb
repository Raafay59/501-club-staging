require 'rails_helper'

RSpec.describe "Faqs", type: :request do
  let!(:admin) { User.create!(email: 'admin@example.com', role: 'admin') }
  let!(:editor) { User.create!(email: 'editor@example.com', role: 'editor') }
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  before { login_as(admin) }

  let!(:faq) { Faq.create!(year: 2025, question: 'What is this?', answer: 'A contest.') }

  let(:valid_attributes) { { year: 2025, question: 'When?', answer: 'March.' } }
  let(:invalid_attributes) { { year: nil, question: nil, answer: nil } }

  describe "GET /faqs" do
    it "returns a successful response" do
      get faqs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /faqs/:id" do
    it "returns a successful response" do
      get faq_path(faq)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /faqs/new" do
    it "returns a successful response" do
      get new_faq_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /faqs" do
    context "with valid parameters" do
      it "creates a new FAQ and redirects" do
        expect {
          post faqs_path, params: { faq: valid_attributes }
        }.to change(Faq, :count).by(1)
        expect(response).to redirect_to(faqs_path)
      end
    end

    context "with invalid parameters" do
      it "does not create and re-renders the form" do
        expect {
          post faqs_path, params: { faq: invalid_attributes }
        }.not_to change(Faq, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /faqs/:id/edit" do
    it "returns a successful response" do
      get edit_faq_path(faq)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /faqs/:id" do
    context "with valid parameters" do
      it "updates and redirects" do
        patch faq_path(faq), params: { faq: { question: 'Updated?' } }
        faq.reload
        expect(faq.question).to eq('Updated?')
        expect(response).to redirect_to(faqs_path)
      end
    end

    context "with invalid parameters" do
      it "does not update and re-renders the form" do
        patch faq_path(faq), params: { faq: { question: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /faqs/:id/delete" do
    it "returns a successful response" do
      get delete_faq_path(faq)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /faqs/:id" do
    it "deletes and redirects" do
      expect {
        delete faq_path(faq)
      }.to change(Faq, :count).by(-1)
      expect(response).to redirect_to(faqs_path)
    end

    context "as a non-admin editor" do
      before { login_as(editor) }

      it "redirects non-admin users" do
        delete faq_path(faq)
        expect(response).to redirect_to(ideathons_path)
      end
    end
  end

  describe "POST /faqs/import" do
    it "imports from a valid CSV file" do
      file = fixture_file_upload('faqs.csv', 'text/csv')

      expect {
        post import_faqs_path, params: { file: file }
      }.to change(Faq, :count).by(2)

      expect(response).to redirect_to(faqs_path)
    end

    it "rejects non-csv files" do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')

      expect {
        post import_faqs_path, params: { file: file }
      }.not_to change(Faq, :count)

      expect(response).to redirect_to(faqs_path)
      expect(flash[:alert]).to include('Invalid file type')
    end
  end
end
