require 'rails_helper'

RSpec.describe "MentorsJudges", type: :request do
  let!(:admin) { User.create!(email: 'admin@example.com', role: 'admin') }
  let!(:editor) { User.create!(email: 'editor@example.com', role: 'editor') }
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  before { login_as(admin) }

  let!(:mentors_judge) { MentorsJudge.create!(year: 2025, name: 'Alice Smith', bio: 'Expert', is_judge: true) }

  let(:valid_attributes) { { year: 2025, name: 'Bob Jones', bio: 'Mentor', is_judge: false } }
  let(:invalid_attributes) { { year: nil, name: nil } }

  describe "GET /mentors_judges" do
    it "returns a successful response" do
      get mentors_judges_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /mentors_judges/:id" do
    it "returns a successful response" do
      get mentors_judge_path(mentors_judge)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /mentors_judges/new" do
    it "returns a successful response" do
      get new_mentors_judge_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /mentors_judges" do
    context "with valid parameters" do
      it "creates a new mentor/judge and redirects" do
        expect {
          post mentors_judges_path, params: { mentors_judge: valid_attributes }
        }.to change(MentorsJudge, :count).by(1)
        expect(response).to redirect_to(mentors_judges_path)
      end
    end

    context "with invalid parameters" do
      it "does not create and re-renders the form" do
        expect {
          post mentors_judges_path, params: { mentors_judge: invalid_attributes }
        }.not_to change(MentorsJudge, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /mentors_judges/:id/edit" do
    it "returns a successful response" do
      get edit_mentors_judge_path(mentors_judge)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /mentors_judges/:id" do
    context "with valid parameters" do
      it "updates and redirects" do
        patch mentors_judge_path(mentors_judge), params: { mentors_judge: { name: 'Updated Name' } }
        mentors_judge.reload
        expect(mentors_judge.name).to eq('Updated Name')
        expect(response).to redirect_to(mentors_judges_path)
      end
    end

    context "with invalid parameters" do
      it "does not update and re-renders the form" do
        patch mentors_judge_path(mentors_judge), params: { mentors_judge: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /mentors_judges/:id/delete" do
    it "returns a successful response" do
      get delete_mentors_judge_path(mentors_judge)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /mentors_judges/:id" do
    it "deletes and redirects" do
      expect {
        delete mentors_judge_path(mentors_judge)
      }.to change(MentorsJudge, :count).by(-1)
      expect(response).to redirect_to(mentors_judges_path)
    end

    context "as a non-admin editor" do
      before { login_as(editor) }

      it "redirects non-admin users" do
        delete mentors_judge_path(mentors_judge)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /mentors_judges/import" do
    it "imports from a valid CSV file" do
      file = fixture_file_upload('mentors_judges.csv', 'text/csv')
      expect {
        post import_mentors_judges_path, params: { file: file }
      }.to change(MentorsJudge, :count).by(2)
      expect(response).to redirect_to(mentors_judges_path)
    end

    it "shows alert when import has failures" do
      file = fixture_file_upload('invalid_judges.csv', 'text/csv')
      post import_mentors_judges_path, params: { file: file }
      expect(response).to redirect_to(mentors_judges_path)
    end
  end
end
