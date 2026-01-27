require "rails_helper"
require "cgi"

RSpec.describe XShareHelper, type: :helper do
  describe "#my_timetable_share_url" do
    let(:festival) { create(:festival, name: "Test Fest") }
    let(:day) { festival.start_date }

    around do |example|
      old_host = Rails.application.routes.default_url_options[:host]
      Rails.application.routes.default_url_options[:host] = "example.com"
      example.run
      Rails.application.routes.default_url_options[:host] = old_host
    end

    it "embeds the owner UUID in the shared URL" do
      owner_uuid = "uuid-1234"

      share_url = helper.my_timetable_share_url(festival: festival, day: day, owner_uuid: owner_uuid)
      decoded = CGI.unescape(share_url)

      expect(decoded).to include("user_id=#{owner_uuid}")
    end
  end
end
