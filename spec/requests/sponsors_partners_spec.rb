require "rails_helper"

RSpec.describe "SponsorsPartners", type: :request do
     let(:admin) { Admin.create!(email: "admin@tamu.edu", full_name: "Admin", uid: "123") }
     let(:editor) { Admin.create!(email: "editor@tamu.edu", full_name: "Editor", uid: "ed-1", role: "editor") }
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     describe "GET /dashboard/sponsors_partners" do
          it "renders for authorized users" do
               sign_in editor, scope: :admin
               get sponsors_partners_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "POST /dashboard/sponsors_partners" do
          before { sign_in editor, scope: :admin }

          it "creates sponsor and keeps logo when include_logo is true" do
               post sponsors_partners_path, params: {
                 sponsors_partner: {
                   year: 2026,
                   name: "ACME",
                   job_title: "Gold",
                   logo_url: "https://example.com/logo.png",
                   blurb: "Bio",
                   is_sponsor: true,
                   include_logo: "1"
                 }
               }

               expect(response).to redirect_to(sponsors_partners_path)
               expect(SponsorsPartner.last.logo_url).to eq("https://example.com/logo.png")
          end

          it "clears logo when include_logo is false" do
               post sponsors_partners_path, params: {
                 sponsors_partner: {
                   year: 2026,
                   name: "No Logo Co",
                   logo_url: "https://example.com/logo.png",
                   is_sponsor: false,
                   include_logo: "0"
                 }
               }

               expect(response).to redirect_to(sponsors_partners_path)
               expect(SponsorsPartner.last.logo_url).to be_nil
          end
     end

     describe "GET /dashboard/sponsors_partners/export" do
          before { sign_in admin, scope: :admin }

          it "exports sponsors from the latest year that actually has sponsors" do
               older_year = Ideathon.create!(year: 2025, name: "Ideathon 2025")

               SponsorsPartner.create!(
                 ideathon: older_year,
                 name: "Legacy Sponsor",
                 job_title: "Gold",
                 blurb: "Sponsor from older year",
                 is_sponsor: true
               )

               get export_sponsors_partners_path(format: :csv)

               expect(response).to have_http_status(:ok)
               expect(response.content_type).to include("text/csv")
               expect(response.body).to include("Legacy Sponsor")
          end

          it "shows an alert when no sponsors exist in any year" do
               get export_sponsors_partners_path(format: :csv)

               expect(response).to redirect_to(sponsors_partners_path)
               expect(flash[:alert]).to eq("No sponsors to export")
          end
     end

     describe "POST /dashboard/sponsors_partners/import" do
          it "blocks editors from import" do
               sign_in editor, scope: :admin
               post import_sponsors_partners_path, params: { file: nil }
               expect(response).to redirect_to(root_path)
          end

          it "imports sponsors from a real csv upload" do
               sign_in admin, scope: :admin
               csv = Tempfile.new([ "sponsors", ".csv" ])
               csv.write("year,name,job_title,logo_url,blurb,is_sponsor\n2026,ACME Corp,Gold,https://example.com/logo.png,Great sponsor,true\n")
               csv.rewind
               upload = Rack::Test::UploadedFile.new(csv.path, "text/csv", original_filename: "sponsors.csv")

               expect do
                    post import_sponsors_partners_path, params: { file: upload }
               end.to change(SponsorsPartner, :count).by(1)

               expect(response).to redirect_to(sponsors_partners_path)
               expect(flash[:notice]).to include("imported successfully")
               expect(SponsorsPartner.find_by(name: "ACME Corp")).to be_present
          ensure
               csv&.close
               csv&.unlink
          end
     end

     describe "PATCH /dashboard/sponsors_partners/:id" do
          before { sign_in editor, scope: :admin }

          it "updates sponsor attributes" do
               sponsor = SponsorsPartner.create!(ideathon: ideathon, name: "ACME", is_sponsor: true)
               patch sponsors_partner_path(sponsor), params: {
                 sponsors_partner: {
                   year: 2026,
                   name: "ACME Updated",
                   logo_url: "",
                   include_logo: "0"
                 }
               }
               expect(response).to redirect_to(sponsors_partners_path)
               expect(sponsor.reload.name).to eq("ACME Updated")
          end
     end

     describe "DELETE /dashboard/sponsors_partners/:id" do
          let!(:sponsor) { SponsorsPartner.create!(ideathon: ideathon, name: "Delete Me", is_sponsor: true) }

          it "blocks editors from delete" do
               sign_in editor, scope: :admin
               delete sponsors_partner_path(sponsor)
               expect(response).to redirect_to(root_path)
          end

          it "allows admins to delete" do
               sign_in admin, scope: :admin
               expect { delete sponsors_partner_path(sponsor) }.to change(SponsorsPartner, :count).by(-1)
               expect(response).to redirect_to(sponsors_partners_path)
          end
     end
end
