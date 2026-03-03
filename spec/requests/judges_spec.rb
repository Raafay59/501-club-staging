require 'rails_helper'

RSpec.describe "Judges", type: :request do
    let(:valid_attributes) do
        {
            judge_name: "John Doe",
            judge_title: "Senior Judge",
            judge_bio: "An experienced judge.",
            ideathon: 2026
        }
    end

    let (:invalid_attributes) do
        {
            judge_name: nil,
            judge_title: nil,
            judge_bio: nil,
            ideathon: nil
        }
    end

    let!(:judge) { Judge.create!(valid_attributes) }

    describe "GET /judges" do
        it "returns a successful response" do
            get judges_path
            expect(response).to have_http_status(:ok)
        end
    end

    describe "GET /judges/:id" do
        it "returns a successful response" do
            get judge_path(judge)
            expect(response).to have_http_status(:ok)
        end
    end

    describe "GET /judges/new" do
        it "returns a successful response" do
            get new_judge_path
            expect(response).to have_http_status(:ok)
        end
    end

    describe "POST /judges" do
        context "with valid parameters" do
            it "creates a new judge and redirects to index" do
                expect {
                    post judges_path, params: { judge: valid_attributes }
                }.to change(Judge, :count).by(1)
                expect(response).to redirect_to(judges_path)
            end
        end

        context "with invalid parameters" do
            it "does not create a new judge and re-renders the new template" do
                expect {
                    post judges_path, params: { judge: invalid_attributes }
                }.not_to change(Judge, :count)
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    describe "PATCH /judges/:id" do
        context "with valid parameters" do
            it "updates the judge and redirects to index" do
                patch judge_path(judge), params: { judge: { judge_name: "Jane Doe" } }
                judge.reload
                expect(judge.judge_name).to eq("Jane Doe")
                expect(response).to redirect_to(judges_path)
            end
        end

        context "with invalid parameters" do
            it "does not update the judge and re-renders the edit template" do
                patch judge_path(judge), params: { judge: invalid_attributes }
                judge.reload
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    describe "DELETE /judges/:id" do
        it "deletes the judge and redirects to index" do
            expect {
                delete judge_path(judge)
            }.to change(Judge, :count).by(-1)
            expect(response).to redirect_to(judges_path)
        end
    end

    describe "GET /judges/:id/delete" do
        it "returns a successful response" do
            get delete_judge_path(judge)
            expect(response).to have_http_status(:ok)
        end
    end

    describe "GET /judges/:id/edit" do
        it "returns a successful response" do
            get edit_judge_path(judge)
            expect(response).to have_http_status(:ok)
        end
    end
end
