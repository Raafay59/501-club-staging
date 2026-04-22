require "rails_helper"

RSpec.describe "Ideathons dashboard", type: :request do
     let(:admin_user) { Admin.create!(email: "ideathon-admin@tamu.edu", full_name: "Admin", uid: "ia-1", role: "admin") }
     let(:editor_user) { Admin.create!(email: "ideathon-editor@tamu.edu", full_name: "Editor", uid: "ie-1", role: "editor") }

     let!(:active_year) { Ideathon.create!(year: 2025, name: "Ideathon 2025", is_active: true) }
     let!(:target_year) { Ideathon.create!(year: 2026, name: "Ideathon 2026", is_active: false) }

     describe "GET /dashboard/ideathons" do
          it "requires login" do
               get ideathons_path
               expect(response).to redirect_to(new_admin_session_path)
          end

          it "allows authorized users" do
               sign_in editor_user, scope: :admin
               get ideathons_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "POST /dashboard/ideathons" do
          before { sign_in editor_user, scope: :admin }

          it "creates and activates new year exclusively" do
               post ideathons_path, params: {
                 ideathon: {
                   year: 2027,
                   name: "Ideathon 2027",
                   theme: "Build",
                   is_active: true
                 }
               }

               expect(response).to redirect_to(ideathons_path)
               expect(Ideathon.find_by(year: 2027)&.is_active).to eq(true)
               expect(active_year.reload.is_active).to eq(false)
          end

          it "renders new on invalid create" do
               post ideathons_path, params: { ideathon: { year: 20, name: "Bad Year" } }
               expect(response).to have_http_status(:unprocessable_content)
          end
     end

     describe "PATCH /dashboard/ideathons/:year" do
          before { sign_in editor_user, scope: :admin }

          it "updates ideathon and toggles active flag exclusively" do
               patch ideathon_path(year: target_year.year), params: {
                 ideathon: { name: "Updated 2026", is_active: true }
               }

               expect(response).to redirect_to(ideathons_path)
               expect(target_year.reload.name).to eq("Updated 2026")
               expect(target_year.is_active).to eq(true)
               expect(active_year.reload.is_active).to eq(false)
          end
     end

     describe "GET /dashboard/ideathons/:year/overview" do
          before { sign_in editor_user, scope: :admin }

          it "redirects with alert when year is missing" do
               get overview_ideathon_path(year: 2099)
               expect(response).to redirect_to(ideathons_path)
               expect(flash[:alert]).to match(/not found/i)
          end
     end

     describe "POST /dashboard/ideathons/import" do
          it "blocks editors from import" do
               sign_in editor_user, scope: :admin
               post import_ideathons_path, params: { file: nil }
               expect(response).to redirect_to(root_path)
          end

          it "imports ideathons from a real csv upload" do
               sign_in admin_user, scope: :admin
               csv = Tempfile.new([ "ideathons", ".csv" ])
               csv.write("year,theme\n2029,Build The Future\n")
               csv.rewind
               upload = Rack::Test::UploadedFile.new(csv.path, "text/csv", original_filename: "ideathons.csv")

               expect do
                    post import_ideathons_path, params: { file: upload }
               end.to change(Ideathon, :count).by(1)

               expect(response).to redirect_to(ideathons_path)
               expect(flash[:notice]).to match(/imported successfully/i)
               expect(Ideathon.find_by(year: 2029)&.theme).to eq("Build The Future")
          ensure
               csv&.close
               csv&.unlink
          end
     end

     describe "DELETE /dashboard/ideathons/:year" do
          it "blocks editors from deletion" do
               sign_in editor_user, scope: :admin
               delete ideathon_path(year: target_year.year)
               expect(response).to redirect_to(root_path)
          end

          it "handles invalid foreign key failures gracefully" do
               sign_in admin_user, scope: :admin
               allow_any_instance_of(Ideathon).to receive(:destroy).and_raise(ActiveRecord::InvalidForeignKey.new("fk"))

               delete ideathon_path(year: target_year.year)

               expect(response).to redirect_to(ideathons_path)
               expect(flash[:alert]).to match(/related records still exist/i)
          end
     end
end
