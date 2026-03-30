require "rails_helper"

RSpec.describe ActivityLog, type: :model do
  let(:user) { User.create!(email: "admin@example.com", role: "admin") }

  describe ".record!" do
    it "infers structured metadata from the message" do
      log = described_class.record!(user: user, action: :added, message: "Sponsor 'Acme' was added")

      expect(log.content_type).to eq("sponsors")
      expect(log.item_name).to eq("Acme")
    end
  end

  describe "immutability" do
    let!(:log) { described_class.record!(user: user, action: :added, message: "Sponsor 'Acme' was added") }

    it "cannot be edited" do
      expect(log.update(message: "Changed")).to be(false)
      expect(log.errors[:base]).to include("Activity logs are immutable")
    end

    it "cannot be deleted" do
      expect {
        log.destroy
      }.not_to change(described_class, :count)

      expect(log.errors[:base]).to include("Activity logs are immutable")
    end
  end
end
