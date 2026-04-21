# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin, type: :model do
     describe ".allowed_email?" do
          it "returns false when email is blank" do
               expect(Admin.allowed_email?(nil)).to eq(false)
               expect(Admin.allowed_email?("")).to eq(false)
          end

          it "returns false when ALLOWED_ADMIN_EMAILS is not set" do
               allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("")
               expect(Admin.allowed_email?("any@tamu.edu")).to eq(false)
          end

          it "returns true when email is in the allowlist (comma-separated)" do
               allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("admin@tamu.edu, other@tamu.edu")
               expect(Admin.allowed_email?("admin@tamu.edu")).to eq(true)
               expect(Admin.allowed_email?("other@tamu.edu")).to eq(true)
          end

          it "returns false when email is not in the allowlist" do
               allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("admin@tamu.edu")
               expect(Admin.allowed_email?("user@gmail.com")).to eq(false)
          end
     end

     describe "email domain validation" do
          it "requires email presence" do
               admin = Admin.new(email: nil)
               admin.valid?
               expect(admin.errors[:email]).to include("can't be blank")
          end

          it "requires @tamu.edu emails" do
               admin = Admin.new(email: "user@gmail.com")
               admin.valid?
               expect(admin.errors[:email]).to include("must end with @tamu.edu")
          end
     end

     describe ".from_google" do
          let(:email) { "admin@tamu.edu" }
          let(:full_name) { "Test Admin" }
          let(:uid) { "123456789" }
          let(:avatar_url) { "https://example.com/avatar.jpg" }

          before do
               allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("admin@tamu.edu")
          end

          context "when email is not in allowlist" do
               before do
                    allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("other@tamu.edu")
               end

               it "returns nil and does not create an admin" do
                    expect {
                         Admin.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
                    }.not_to change(Admin, :count)
                    expect(Admin.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)).to be_nil
               end
          end

          context "when email is in allowlist and admin does not exist" do
               it "creates a new admin" do
                    expect {
                         Admin.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
                    }.to change(Admin, :count).by(1)
               end

               it "sets the correct attributes" do
                    admin = Admin.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
                    expect(admin.email).to eq(email)
                    expect(admin.full_name).to eq(full_name)
                    expect(admin.uid).to eq(uid)
                    expect(admin.avatar_url).to eq(avatar_url)
                    expect(admin.role).to eq("editor")
               end
          end

          context "when email is in allowlist and admin already exists" do
               let!(:existing_admin) do
                    Admin.create!(email: email, full_name: "Old Name", uid: "old_uid", avatar_url: "old_url")
               end

               it "does not create a new admin" do
                    expect {
                         Admin.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
                    }.not_to change(Admin, :count)
               end

               it "returns the existing admin and updates attributes" do
                    admin = Admin.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
                    expect(admin.id).to eq(existing_admin.id)
                    expect(admin.full_name).to eq(full_name)
                    expect(admin.uid).to eq(uid)
                    expect(admin.avatar_url).to eq(avatar_url)
               end
          end
     end
end
