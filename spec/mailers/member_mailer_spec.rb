require "rails_helper"

RSpec.describe MemberMailer, type: :mailer do
  describe "role_changed" do
    let(:user) do
      User.create!(
        email: "user@example.com",
        role: "unauthorized"
      )
    end

    it "sends an email to the user when their role changes" do
      mail = MemberMailer.with(user: user, old_role: "unauthorized", new_role: "admin").role_change_email
      expect(mail.to).to eq([ "user@example.com" ])
      expect(mail.subject).to eq("Your role has been changed")
      expect(mail.body.encoded).to include("Your role in the Ideathon Organizer Team has been changed from unauthorized to admin.")
    end

    it "delivers the email" do
      expect {
        MemberMailer.with(user: user, old_role: "unauthorized", new_role: "admin").role_change_email.deliver_now
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "welcome_email" do
    let(:user) do
      User.create!(
        email: "user@example.com",
        role: "unauthorized"
      )
    end

    it "sends a welcome email to the user when they are created" do
      mail = MemberMailer.with(user: user, new_role: user.role).welcome_email
      expect(mail.to).to eq([ "user@example.com" ])
      expect(mail.subject).to eq("Welcome to the Ideathon Organizer Team!")
      expect(mail.body.encoded).to include("Thank you for joining the Ideathon Organizer Team!")
    end

    it "delivers the welcome email" do
      expect {
        MemberMailer.with(user: user, new_role: user.role).welcome_email.deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "goodbye_email" do
    let(:user) do
      User.create!(
        email: "user@example.com",
        role: "unauthorized"
      )
    end

    it "sends a goodbye email to the user when their role is changed to unauthorized" do
      mail = MemberMailer.with(user: user).goodbye_email
      expect(mail.to).to eq([ "user@example.com" ])
      expect(mail.subject).to eq("Removed from the Ideathon Organizer Team")
      expect(mail.body.encoded).to include("We want to thank you for your contributions and time with the team.")
    end

    it "delivers the goodbye email" do
      expect {
        MemberMailer.with(user: user).goodbye_email.deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "request_email" do
    let(:admin) do
      User.create!(
        email: "admin@example.com",
        role: "admin"
      )
    end

    let(:user) do
      User.create!(
        email: "user@example.com",
        role: "unauthorized"
      )
    end

    it "sends a request email to the admin when a user requests a role change" do
      mail = MemberMailer.with(user: admin, requester: user).request_email
      expect(mail.to).to eq([ "admin@example.com" ])
      expect(mail.subject).to eq("New request for editor access")
      expect(mail.body.encoded).to include("#{user.name} has requested to join the Ideathon Organizer Team!")
    end

    it "delivers the request email" do
      expect {
        User.where(role: "admin").find_each do |admin|
          MemberMailer.with(user: admin, requester: user).request_email.deliver_now
        end
      }.to change { ActionMailer::Base.deliveries.count }.by(User.where(role: "admin").count)
    end
  end
end
