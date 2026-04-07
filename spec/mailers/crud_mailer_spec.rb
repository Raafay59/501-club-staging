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
        name: "Actor User",
        role: "admin"
      )
    end

    let (:change_type) { "edited" }
    let(:change_message) { "Sponsor 'Acme' was edited" }
    let(:item_name) { "Acme" }
    let(:changed_at) { Time.zone.parse("2026-04-07 09:30:00 UTC") }
    subject(:mail) do
      CrudMailer.with(
        user: user,
        change_type: change_type,
        actor: actor,
        change_message: change_message,
        item_name: item_name,
        changed_at: changed_at
      ).record_change_email
    end

    it "renders the subject" do
      expect(mail.subject).to eq("A record has been edited")
    end

    it "sends the email to the correct recipient" do
      expect(mail.to).to eq([ "recipient@example.com" ])
    end

    it "includes what changed, who changed it, and when" do
      expect(mail.body.encoded).to include("Sponsor &#39;Acme&#39; was edited")
      expect(mail.body.encoded).to include("Actor User")
      expect(mail.body.encoded).to include("2026-04-07")
    end
  end
end
