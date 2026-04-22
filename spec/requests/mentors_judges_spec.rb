require "rails_helper"

RSpec.describe "MentorsJudges dashboard", type: :request do
     let(:admin_user) { Admin.create!(email: "mentor-admin@tamu.edu", full_name: "Admin", uid: "mj-a", role: "admin") }
     let(:editor_user) { Admin.create!(email: "mentor-editor@tamu.edu", full_name: "Editor", uid: "mj-e", role: "editor") }
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     describe "GET /dashboard/mentors_judges" do
          it "renders for authorized users" do
               sign_in editor_user, scope: :admin
               get mentors_judges_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "POST /dashboard/mentors_judges" do
          before { sign_in editor_user, scope: :admin }

          it "creates without photo when include_photo is unchecked" do
               post mentors_judges_path, params: {
                 mentors_judge: {
                   year: 2026,
                   name: "Mentor A",
                   job_title: "Engineer",
                   photo_url: "https://example.com/photo.png",
                   bio: "Bio",
                   is_judge: false,
                   include_photo: "0"
                 }
               }

               expect(response).to redirect_to(mentors_judges_path)
               expect(MentorsJudge.last.photo_url).to be_nil
          end

          it "re-renders form on invalid create" do
               post mentors_judges_path, params: {
                 mentors_judge: {
                   year: 2026,
                   name: "",
                   include_photo: "1"
                 }
               }

               expect(response).to have_http_status(:unprocessable_content)
          end
     end

     describe "GET /dashboard/mentors_judges/export" do
          it "blocks editors from export" do
               sign_in editor_user, scope: :admin
               get export_mentors_judges_path(format: :csv)
               expect(response).to redirect_to(root_path)
          end

          it "shows alert when no judges exist" do
               sign_in admin_user, scope: :admin
               get export_mentors_judges_path(format: :csv)
               expect(response).to redirect_to(mentors_judges_path)
               expect(flash[:alert]).to eq("No judges to export")
          end

          it "exports csv for latest year with judges" do
               sign_in admin_user, scope: :admin
               MentorsJudge.create!(
                 ideathon: ideathon,
                 name: "Judge Z",
                 job_title: "CTO",
                 bio: "Bio",
                 is_judge: true
               )

               get export_mentors_judges_path(format: :csv)

               expect(response).to have_http_status(:ok)
               expect(response.content_type).to include("text/csv")
               expect(response.body).to include("Judge Z")
          end
     end

     describe "POST /dashboard/mentors_judges/import" do
          it "imports mentors/judges from a real csv upload" do
               sign_in admin_user, scope: :admin
               csv = Tempfile.new([ "mentors_judges", ".csv" ])
               csv.write("year,name,job_title,photo_url,bio,is_judge\n2026,Judge Dredd,Chief Judge,https://example.com/judge.png,Bio,true\n")
               csv.rewind
               upload = Rack::Test::UploadedFile.new(csv.path, "text/csv", original_filename: "mentors_judges.csv")

               expect do
                    post import_mentors_judges_path, params: { file: upload }
               end.to change(MentorsJudge, :count).by(1)

               expect(response).to redirect_to(mentors_judges_path)
               expect(flash[:notice]).to include("imported successfully")
               expect(MentorsJudge.find_by(name: "Judge Dredd")).to be_present
          ensure
               csv&.close
               csv&.unlink
          end
     end

     describe "PATCH /dashboard/mentors_judges/:id" do
          before { sign_in editor_user, scope: :admin }

          it "updates mentor/judge record" do
               mentor = MentorsJudge.create!(ideathon: ideathon, name: "Mentor A", is_judge: false)
               patch mentors_judge_path(mentor), params: {
                 mentors_judge: {
                   year: 2026,
                   name: "Mentor B",
                   is_judge: true,
                   include_photo: "0"
                 }
               }

               expect(response).to redirect_to(mentors_judges_path)
               expect(mentor.reload.name).to eq("Mentor B")
               expect(mentor.is_judge).to eq(true)
          end
     end

     describe "DELETE /dashboard/mentors_judges/:id" do
          let!(:mentor) { MentorsJudge.create!(ideathon: ideathon, name: "Delete Judge", is_judge: true) }

          it "allows admins to delete" do
               sign_in admin_user, scope: :admin
               expect { delete mentors_judge_path(mentor) }.to change(MentorsJudge, :count).by(-1)
               expect(response).to redirect_to(mentors_judges_path)
          end
     end
end
