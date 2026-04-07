require "rails_helper"

RSpec.describe ActivityLog, type: :model do
  include ActiveJob::TestHelper

  let(:user) { User.create!(email: "admin@example.com", role: "admin") }

  before do
    clear_enqueued_jobs
    ActionMailer::Base.deliveries.clear
  end

  describe ".record!" do
    it "infers structured metadata from the message" do
      log = described_class.record!(user: user, action: :added, message: "Sponsor 'Acme' was added")

      expect(log.content_type).to eq("sponsors")
      expect(log.item_name).to eq("Acme")
    end
  end

  describe "organizer notifications" do
    let!(:admin_recipient) { User.create!(email: "notify-admin@example.com", role: "admin") }
    let!(:editor_recipient) { User.create!(email: "notify-editor@example.com", role: "editor") }
    let!(:unauthorized_user) { User.create!(email: "notify-unauthorized@example.com", role: "unauthorized") }

    before do
      clear_enqueued_jobs
      ActionMailer::Base.deliveries.clear
    end

    it "emails only organizers when a log is committed" do
      perform_enqueued_jobs do
        described_class.record!(user: unauthorized_user, action: :added, message: "Sponsor 'Acme' was added")
      end

      recipients = ActionMailer::Base.deliveries.flat_map(&:to)
      expect(recipients).to contain_exactly(admin_recipient.email, editor_recipient.email)
    end

    it "does not enqueue notifications when transaction rolls back" do
      ActiveRecord::Base.transaction do
        described_class.record!(user: unauthorized_user, action: :added, message: "Sponsor 'Rollback' was added")
        raise ActiveRecord::Rollback
      end

      expect(enqueued_jobs).to be_empty
    end

    it "keeps activity log creation when enqueueing fails" do
      allow(CrudMailer).to receive(:with).and_raise(StandardError, "queue failed")

      expect {
        described_class.record!(user: unauthorized_user, action: :added, message: "Sponsor 'Safe' was added")
      }.to change(described_class, :count).by(1)
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
