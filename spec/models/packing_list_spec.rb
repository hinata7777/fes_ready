require "rails_helper"

RSpec.describe PackingList, type: :model do
  describe "バリデーション" do
    it "デフォルトのファクトリなら有効" do
      expect(build(:packing_list)).to be_valid
    end

    it "titleは必須" do
      packing_list = build(:packing_list, title: nil)
      expect(packing_list).to be_invalid
      expect(packing_list.errors[:title]).to be_present
    end

    it "titleは100文字以内" do
      packing_list = build(:packing_list, title: "a" * 101)
      expect(packing_list).to be_invalid
    end

    it "templateでなければuserが必須" do
      packing_list = build(:packing_list, user: nil, template: false)
      expect(packing_list).to be_invalid
      expect(packing_list.errors[:user_id]).to be_present
    end

    it "templateならuserなしでよい" do
      expect(build(:template_packing_list)).to be_valid
    end

    it "非テンプレはユーザー内でtitleユニーク" do
      user = create(:user)
      create(:packing_list, user: user, title: "被り不可")

      duplicate = build(:packing_list, user: user, title: "被り不可")
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:title]).to be_present
    end

    it "別ユーザーなら同名titleを許可" do
      title = "同名OK"
      create(:packing_list, title: title)

      expect(build(:packing_list, title: title)).to be_valid
    end

    it "templateフラグは真偽値のみ" do
      packing_list = build(:packing_list, template: nil)
      expect(packing_list).to be_invalid
    end

    it "過去の日程は選べない" do
      festival = create(:festival, start_date: Date.current - 10, end_date: Date.current - 5)
      past_day = create(:festival_day, festival: festival, date: festival.start_date)

      packing_list = build(:packing_list, festival_day: past_day)
      expect(packing_list).to be_invalid
      expect(packing_list.errors[:festival_day]).to include("は開催前の日程を選んでください")
    end

    it "未来の日程ならOK" do
      festival = create(:festival, start_date: Date.current + 10, end_date: Date.current + 11)
      upcoming_day = create(:festival_day, festival: festival, date: festival.start_date)

      expect(build(:packing_list, festival_day: upcoming_day)).to be_valid
    end
  end

  describe "スコープ" do
    it ".templates はテンプレートのみ返す" do
      template = create(:template_packing_list)
      owned = create(:packing_list)

      expect(PackingList.templates).to include(template)
      expect(PackingList.templates).not_to include(owned)
    end

    it ".owned_by は指定ユーザーのリストのみ返す" do
      user = create(:user)
      owned = create(:packing_list, user: user)
      other = create(:packing_list)

      expect(PackingList.owned_by(user)).to contain_exactly(owned)
      expect(PackingList.owned_by(user)).not_to include(other)
    end
  end

  describe "#to_param" do
    it "uuidをそのまま返す" do
      packing_list = create(:packing_list)
      expect(packing_list.to_param).to eq(packing_list.uuid)
    end
  end

  describe "#past_selected_festival_day" do
    it "日程未設定ならnilを返す" do
      expect(build(:packing_list).past_selected_festival_day).to be_nil
    end

    it "未来の日程ならnilを返す" do
      festival = create(:festival, start_date: Date.current + 1, end_date: Date.current + 2)
      day = create(:festival_day, festival: festival, date: festival.start_date)
      packing_list = build(:packing_list, festival_day: day)

      expect(packing_list.past_selected_festival_day).to be_nil
    end

    it "終了済みの日程ならその日程を返す" do
      festival = create(:festival, start_date: Date.current - 10, end_date: Date.current - 5)
      day = create(:festival_day, festival: festival, date: festival.start_date)
      packing_list = build(:packing_list, festival_day: day)

      expect(packing_list.past_selected_festival_day(Date.current)).to eq(day)
    end
  end
end
