require 'rails_helper'

RSpec.describe "judges/edit.html.erb", type: :view do
  let(:judge) do
    Judge.create!(
      judge_name: "MyString",
      judge_title: "MyString",
      judge_bio: "MyText",
      ideathon: 2026
    )
  end

  before do
    assign(:judge, judge)
  end

  it "renders the edit judge form" do
    render
    expect(rendered).to have_selector("form[action='#{judge_path(judge)}'][method='post']")
  end

  it "renders the judge_name field" do
    render
    expect(rendered).to have_field('judge[judge_name]', with: "MyString")
  end

  it "renders the judge_title field" do
    render
    expect(rendered).to have_field('judge[judge_title]', with: "MyString")
  end

  it "renders the judge_bio field" do
    render
    expect(rendered).to have_field('judge[judge_bio]', with: "MyText")
  end

  it "renders the ideathon field" do
    render
    expect(rendered).to have_field('judge[ideathon]', with: 2026)
  end

  it "renders the submit button" do
    render
    expect(rendered).to have_button('Update Judge')
  end

  it "renders the cancel link" do
    render
    expect(rendered).to have_link('Back', href: judges_path)
  end

  context "when the judge has a photo" do
    before do
      judge.judge_photo.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end

    it "displays the judge's photo" do
      render
      expect(rendered).to have_selector("img")
    end
  end

  it "displays error messages when the judge is invalid" do
    judge = Judge.new(judge_name: "", judge_title: "", judge_bio: "", ideathon: nil)
    judge.validate
    assign(:judge, judge)
    render
    expect(rendered).to include("prohibited this judge from being saved")
  end
end
