require "rails_helper"

RSpec.describe CrudMailer, type: :mailer do
  describe "record_change_email" do
    let(:user) do
      User.create!(
        email: "recipient@example.com",
        role: "admin"
      )
    end
    let(:actor) do
      User.create!(
        email: "actor@example.com",
        role: "admin"
      )
    end

    let (:change_type) { "edited" }
    subject(:mail) do
      CrudMailer.with(
        user: user,
        change_type: change_type,
        actor: actor
      ).record_change_email
    end

    it "renders the subject" do
      expect(mail.subject).to eq("A record has been edited")
    end

    it "sends the email to the correct recipient" do
      expect(mail.to).to eq([ "recipient@example.com" ])
    end
  end
end
