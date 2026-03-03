require 'rails_helper'

RSpec.describe "judges/show.html.erb", type: :view do
  before(:each) do
    @judge = assign(:judge, Judge.create!(
      judge_name: "Judge Name",
      judge_title: "Judge Title",
      judge_bio: "Judge Bio",
      ideathon: 2026
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Judge Name/)
    expect(rendered).to match(/Judge Title/)
    expect(rendered).to match(/Judge Bio/)
    expect(rendered).to match(/2026/)
  end

  it "renders judge photo if attached" do
    @judge.judge_photo.attach(
      io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
    render
    expect(rendered).to include('img')
  end

  it "renders default icon if no photo attached" do
    render
    expect(rendered).to include('Default Icon')
  end

  it "has an edit link" do
    render
    expect(rendered).to have_link('Edit', href: edit_judge_path(@judge))
  end

  it "has a back link" do
    render
    expect(rendered).to have_link('Back', href: judges_path)
  end

  it "has a delete link" do
    render
    expect(rendered).to have_link('Delete', href: delete_judge_path(@judge))
  end
end
