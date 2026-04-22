require "rails_helper"

RSpec.describe "Users", type: :request do
     let(:admin_user) { Admin.create!(email: "admin1@tamu.edu", full_name: "Admin One", uid: "admin-1", role: "admin") }
     let(:second_admin) { Admin.create!(email: "admin2@tamu.edu", full_name: "Admin Two", uid: "admin-2", role: "admin") }
     let(:editor_user) { Admin.create!(email: "editor@tamu.edu", full_name: "Editor", uid: "editor-1", role: "editor") }

     describe "GET /dashboard/users" do
          it "redirects guests to sign in" do
               get users_path
               expect(response).to redirect_to(new_admin_session_path)
          end

          it "blocks editors" do
               sign_in editor_user, scope: :admin
               get users_path
               expect(response).to redirect_to(root_path)
               expect(flash[:alert]).to eq("Only admins can perform this action.")
          end

          it "allows admins" do
               sign_in admin_user, scope: :admin
               get users_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "POST /dashboard/users" do
          before { sign_in admin_user, scope: :admin }

          it "creates an invited user with selected role" do
               expect do
                    post users_path, params: { admin: { email: "new_editor@tamu.edu", role: "editor" } }
               end.to change(Admin, :count).by(1)

               expect(response).to redirect_to(users_path)
               expect(Admin.find_by(email: "new_editor@tamu.edu")&.role).to eq("editor")
          end

          it "rejects non tamu email" do
               expect do
                    post users_path, params: { admin: { email: "bad@gmail.com", role: "editor" } }
               end.not_to change(Admin, :count)

               expect(response).to have_http_status(:unprocessable_content)
          end
     end

     describe "PATCH /dashboard/users/:id" do
          before { sign_in admin_user, scope: :admin }

          it "rejects invalid role values" do
               patch user_path(editor_user), params: { admin: { role: "superadmin" } }
               expect(response).to redirect_to(users_path)
               expect(flash[:alert]).to eq("Invalid role selected.")
          end

          it "prevents demoting the only admin" do
               patch user_path(admin_user), params: { admin: { role: "editor" } }
               expect(response).to redirect_to(users_path)
               expect(flash[:alert]).to eq("Cannot demote the only admin.")
               expect(admin_user.reload.role).to eq("admin")
          end

          it "allows demotion when another admin exists" do
               second_admin
               patch user_path(admin_user), params: { admin: { role: "editor" } }
               expect(response).to redirect_to(users_path)
               expect(admin_user.reload.role).to eq("editor")
          end
     end

     describe "DELETE /dashboard/users/:id" do
          before { sign_in admin_user, scope: :admin }

          it "prevents deleting current admin" do
               delete user_path(admin_user)
               expect(response).to redirect_to(users_path)
               expect(flash[:alert]).to match(/cannot delete your own account/i)
          end

          it "deletes another account" do
               delete user_path(editor_user)
               expect(response).to redirect_to(users_path)
               expect(Admin.find_by(id: editor_user.id)).to be_nil
          end
     end
end
