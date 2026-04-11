require 'rails_helper'

RSpec.describe "Rules", type: :request do
  let!(:admin) { User.create!(email: 'admin@example.com', role: 'admin') }
  let!(:editor) { User.create!(email: 'editor@example.com', role: 'editor') }
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  before { login_as(admin) }

  let!(:rule) { Rule.create!(year: 2025, rule_text: 'Be respectful') }

  let(:valid_attributes) { { year: 2025, rule_text: 'No plagiarism' } }
  let(:invalid_attributes) { { year: nil, rule_text: nil } }

  describe "GET /rules" do
    it "returns a successful response" do
      get rules_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /rules/:id" do
    it "returns a successful response" do
      get rule_path(rule)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /rules/new" do
    it "returns a successful response" do
      get new_rule_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /rules" do
    context "with valid parameters" do
      it "creates a new rule and redirects" do
        expect {
          post rules_path, params: { rule: valid_attributes }
        }.to change(Rule, :count).by(1)
        expect(response).to redirect_to(rules_path)
      end
    end

    context "with invalid parameters" do
      it "does not create and re-renders the form" do
        expect {
          post rules_path, params: { rule: invalid_attributes }
        }.not_to change(Rule, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /rules/:id/edit" do
    it "returns a successful response" do
      get edit_rule_path(rule)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /rules/:id" do
    context "with valid parameters" do
      it "updates and redirects" do
        patch rule_path(rule), params: { rule: { rule_text: 'Updated rule' } }
        rule.reload
        expect(rule.rule_text).to eq('Updated rule')
        expect(response).to redirect_to(rules_path)
      end
    end

    context "with invalid parameters" do
      it "does not update and re-renders the form" do
        patch rule_path(rule), params: { rule: { rule_text: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /rules/:id/delete" do
    it "returns a successful response" do
      get delete_rule_path(rule)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /rules/:id" do
    it "deletes and redirects" do
      expect {
        delete rule_path(rule)
      }.to change(Rule, :count).by(-1)
      expect(response).to redirect_to(rules_path)
    end

    context "as a non-admin editor" do
      before { login_as(editor) }

      it "redirects non-admin users" do
        delete rule_path(rule)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /rules/import" do
    it "imports from a valid CSV file" do
      file = fixture_file_upload('rules.csv', 'text/csv')

      expect {
        post import_rules_path, params: { file: file }
      }.to change(Rule, :count).by(2)

      expect(response).to redirect_to(rules_path)
    end

    it "rejects non-csv files" do
      file = fixture_file_upload('not_a_csv.txt', 'text/plain')

      expect {
        post import_rules_path, params: { file: file }
      }.not_to change(Rule, :count)

      expect(response).to redirect_to(rules_path)
      expect(flash[:alert]).to include('Invalid file type')
    end
  end
end
