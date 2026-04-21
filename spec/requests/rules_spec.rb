require "rails_helper"

RSpec.describe "Rules dashboard", type: :request do
     let(:admin_user) { Admin.create!(email: "rule-admin@tamu.edu", full_name: "Admin", uid: "rule-a", role: "admin") }
     let(:editor_user) { Admin.create!(email: "rule-editor@tamu.edu", full_name: "Editor", uid: "rule-e", role: "editor") }
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }
     let!(:rule) { Rule.create!(ideathon: ideathon, rule_text: "Be kind") }

     describe "POST /dashboard/rules" do
          it "allows editor create" do
               sign_in editor_user, scope: :admin
               expect do
                    post rules_path, params: { rule: { year: 2026, rule_text: "Bring ID" } }
               end.to change(Rule, :count).by(1)
               expect(response).to redirect_to(rules_path)
          end
     end

     describe "GET/PATCH rule member actions" do
          before { sign_in editor_user, scope: :admin }

          it "renders show, edit, and delete confirmation pages" do
               get rule_path(rule)
               expect(response).to have_http_status(:ok)
               get edit_rule_path(rule)
               expect(response).to have_http_status(:ok)
               get delete_rule_path(rule)
               expect(response).to have_http_status(:ok)
          end

          it "updates and invalidates properly" do
               patch rule_path(rule), params: { rule: { year: 2026, rule_text: "Updated rule" } }
               expect(response).to redirect_to(rules_path)
               expect(rule.reload.rule_text).to eq("Updated rule")

               patch rule_path(rule), params: { rule: { year: 2026, rule_text: "" } }
               expect(response).to have_http_status(:unprocessable_content)
          end
     end

     describe "POST /dashboard/rules/import" do
          it "blocks non-admins" do
               sign_in editor_user, scope: :admin
               post import_rules_path, params: { file: nil }
               expect(response).to redirect_to(root_path)
          end

          it "imports rules from a real csv upload" do
               sign_in admin_user, scope: :admin
               csv = Tempfile.new([ "rules", ".csv" ])
               csv.write("year,rule_text\n2026,Bring your student ID\n")
               csv.rewind
               upload = Rack::Test::UploadedFile.new(csv.path, "text/csv", original_filename: "rules.csv")

               expect do
                    post import_rules_path, params: { file: upload }
               end.to change(Rule, :count).by(1)

               expect(response).to redirect_to(rules_path)
               expect(flash[:notice]).to include("imported successfully")
          ensure
               csv&.close
               csv&.unlink
          end
     end

     describe "DELETE /dashboard/rules/:id" do
          it "blocks editors from delete" do
               sign_in editor_user, scope: :admin
               delete rule_path(rule)
               expect(response).to redirect_to(root_path)
          end

          it "allows admins to delete" do
               sign_in admin_user, scope: :admin
               expect { delete rule_path(rule) }.to change(Rule, :count).by(-1)
               expect(response).to redirect_to(rules_path)
          end
     end

     describe "GET /dashboard/rules and /new" do
          it "renders index and new for editor" do
               sign_in editor_user, scope: :admin
               get rules_path
               expect(response).to have_http_status(:ok)
               get new_rule_path
               expect(response).to have_http_status(:ok)
          end
     end
end
