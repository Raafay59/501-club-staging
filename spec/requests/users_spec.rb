require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:admin) { User.create!(email: 'admin@example.com', role: 'admin') }
  let!(:editor) { User.create!(email: 'editor@example.com', role: 'editor') }

  before { login_as(admin) }

  describe "GET /users" do
    it "returns a successful response for admin" do
      get users_path
      expect(response).to have_http_status(:ok)
    end

    context "as a non-admin" do
      before { login_as(editor) }

      it "redirects non-admin users" do
        get users_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user and redirects" do
        expect {
          post users_path, params: { user: { email: 'new@example.com', role: 'editor' } }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(users_path)
      end
    end

    context "with invalid parameters" do
      it "does not create with duplicate email" do
        expect {
          post users_path, params: { user: { email: 'admin@example.com', role: 'editor' } }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /users/:id" do
    it "updates a user's role" do
      patch user_path(editor), params: { user: { role: 'admin' } }
      editor.reload
      expect(editor.role).to eq('admin')
      expect(response).to redirect_to(users_path)
    end

    it "keeps role changes when role-change email enqueue fails" do
      delivery = instance_double(ActionMailer::MessageDelivery)
      mailer = instance_double(MemberMailer, role_change_email: delivery)
      allow(MemberMailer).to receive(:with).and_return(mailer)
      allow(delivery).to receive(:deliver_later).and_raise(StandardError, "queue unavailable")

      patch user_path(editor), params: { user: { role: 'admin' } }

      editor.reload
      expect(editor.role).to eq('admin')
      expect(response).to redirect_to(users_path)
    end

    it "prevents demoting the last admin" do
      patch user_path(admin), params: { user: { role: 'editor' } }
      admin.reload
      expect(admin.role).to eq('admin')
      expect(response).to redirect_to(users_path)
    end
  end

  describe "DELETE /users/:id" do
    it "deletes another user" do
      expect {
        delete user_path(editor)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
    end

    it "prevents deleting yourself" do
      expect {
        delete user_path(admin)
      }.not_to change(User, :count)
      expect(response).to redirect_to(users_path)
    end

    it "prevents deleting a user who has activity logs" do
      ActivityLog.record!(user: editor, action: :added, message: "Sponsor 'Logged' was added")

      expect {
        delete user_path(editor)
      }.not_to change(User, :count)

      expect(response).to redirect_to(users_path)
    end
  end
end
