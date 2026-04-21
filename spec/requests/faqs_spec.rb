require "rails_helper"

RSpec.describe "FAQs dashboard", type: :request do
     let(:admin_user) { Admin.create!(email: "faq-admin@tamu.edu", full_name: "Admin", uid: "faq-a", role: "admin") }
     let(:editor_user) { Admin.create!(email: "faq-editor@tamu.edu", full_name: "Editor", uid: "faq-e", role: "editor") }
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }
     let!(:faq) { Faq.create!(ideathon: ideathon, question: "When?", answer: "Soon") }

     describe "GET /dashboard/faqs" do
          it "requires auth" do
               get faqs_path
               expect(response).to redirect_to(new_admin_session_path)
          end

          it "renders index for editor" do
               sign_in editor_user, scope: :admin
               get faqs_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "POST /dashboard/faqs" do
          before { sign_in editor_user, scope: :admin }

          it "allows editors to create faq entries" do
               expect do
                    post faqs_path, params: { faq: { year: 2026, question: "Where?", answer: "MSC" } }
               end.to change(Faq, :count).by(1)

               expect(response).to redirect_to(faqs_path)
          end

          it "renders validation errors for invalid input" do
               post faqs_path, params: { faq: { year: 2026, question: "", answer: "" } }
               expect(response).to have_http_status(:unprocessable_content)
          end
     end

     describe "POST /dashboard/faqs/import" do
          it "blocks editors" do
               sign_in editor_user, scope: :admin
               post import_faqs_path, params: { file: nil }
               expect(response).to redirect_to(root_path)
          end

          it "imports faq rows from a real csv upload" do
               sign_in admin_user, scope: :admin
               csv = Tempfile.new([ "faqs", ".csv" ])
               csv.write("year,question,answer\n2026,What time does it start?,9 AM\n")
               csv.rewind
               upload = Rack::Test::UploadedFile.new(csv.path, "text/csv", original_filename: "faqs.csv")

               expect do
                    post import_faqs_path, params: { file: upload }
               end.to change(Faq, :count).by(1)

               expect(response).to redirect_to(faqs_path)
               expect(flash[:notice]).to include("imported successfully")
          ensure
               csv&.close
               csv&.unlink
          end
     end

     describe "DELETE /dashboard/faqs/:id" do
          it "blocks editors from delete" do
               sign_in editor_user, scope: :admin
               delete faq_path(faq)
               expect(response).to redirect_to(root_path)
          end

          it "allows admins to delete" do
               sign_in admin_user, scope: :admin
               expect { delete faq_path(faq) }.to change(Faq, :count).by(-1)
               expect(response).to redirect_to(faqs_path)
          end
     end

     describe "GET/PATCH faq member actions" do
          before { sign_in editor_user, scope: :admin }

          it "renders show, edit, and delete confirm pages" do
               get faq_path(faq)
               expect(response).to have_http_status(:ok)
               get edit_faq_path(faq)
               expect(response).to have_http_status(:ok)
               get delete_faq_path(faq)
               expect(response).to have_http_status(:ok)
          end

          it "updates and handles invalid update" do
               patch faq_path(faq), params: { faq: { year: 2026, question: "Updated?", answer: "Yes" } }
               expect(response).to redirect_to(faqs_path)
               expect(faq.reload.question).to eq("Updated?")

               patch faq_path(faq), params: { faq: { year: 2026, question: "", answer: "" } }
               expect(response).to have_http_status(:unprocessable_content)
          end
     end
end
