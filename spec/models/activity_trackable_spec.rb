require "rails_helper"

RSpec.describe "ActivityTrackable callbacks", type: :model do
     let(:admin) { Admin.create!(email: "track-admin@tamu.edu", full_name: "Track Admin", uid: "track-1") }

     around do |example|
          Current.admin = admin
          example.run
          Current.admin = nil
     end

     it "records create, update, and destroy activity for trackable models" do
          ActivityLog.delete_all
          ideathon = nil

          expect do
               ideathon = Ideathon.create!(year: 2090, name: "Ideathon 2090")
          end.to change(ActivityLog, :count).by(1)
          expect(ActivityLog.last.action).to eq("added")

          expect do
               ideathon.update!(name: "Updated Ideathon 2090")
          end.to change(ActivityLog, :count).by(1)
          expect(ActivityLog.last.action).to eq("edited")

          expect do
               ideathon.destroy!
          end.to change(ActivityLog, :count).by(1)
          expect(ActivityLog.last.action).to eq("removed")
     end
end
