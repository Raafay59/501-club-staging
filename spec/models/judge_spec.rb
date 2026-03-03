require 'rails_helper'

RSpec.describe Judge, type: :model do
  it "is valid with valid attributes" do
    judge = Judge.new(
      judge_name: "John Doe",
      judge_title: "Senior Judge",
      judge_bio: "An experienced judge.",
      ideathon: 2026
    )
    expect(judge).to be_valid
  end

  it "is not valid without a judge_name" do
    judge = Judge.new(
      judge_title: "Senior Judge",
      judge_bio: "An experienced judge."
    )
    expect(judge).not_to be_valid
  end

  it "is not valid without a judge_title" do
    judge = Judge.new(
      judge_name: "John Doe",
      judge_bio: "An experienced judge."
    )
    expect(judge).not_to be_valid
  end

  it "is not valid without a judge_bio" do
    judge = Judge.new(
      judge_name: "John Doe",
      judge_title: "Senior Judge"
    )
    expect(judge).not_to be_valid
  end

  it "is not valid without an ideathon" do
    judge = Judge.new(
      judge_name: "John Doe",
      judge_title: "Senior Judge",
      judge_bio: "An experienced judge."
    )
    expect(judge).not_to be_valid
  end
end
