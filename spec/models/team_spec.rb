# frozen_string_literal: true

require "rails_helper"

RSpec.describe Team, type: :model do
     describe "associations" do
          it { is_expected.to belong_to(:ideathon_year) }
          it { is_expected.to have_many(:registered_attendees) }
     end
end
