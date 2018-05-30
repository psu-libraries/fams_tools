require 'rails_helper'
require 'ai_get_userids'

RSpec.describe ImportUserids do

  let(:xml) do
    '<?xml version="1.0" encoding="UTF-8"?>

     <Users xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dmu="http://www.digitalmeasures.com/schema/user-metadata">
	<User username="zzz333" dmu:userId="123456" PSUID="99999909">
		<FirstName>Jimbob</FirstName>
		<LastName>Billy</LastName>
		<Email>zzz333@psu.edu</Email>
		<ShibbolethAuthentication/>
		<Item xlink:type="simple" xlink:href="/login/service/v4/User/USERNAME:zzz333"/>
	</User>
	<User username="yyy444" dmu:userId="654321" PSUID="99999919">
		<FirstName>Yoda</FirstName>
		<MiddleName>Jedi</MiddleName>
		<LastName>Master</LastName>
                <Email>yyy444@psu.edu</Email>
		<ShibbolethAuthentication/>
		<Item xlink:type="simple" xlink:href="/login/service/v4/User/USERNAME:yyy444"/>
	</User>
	<User username="rrr111" dmu:userId="987654" PSUID="999999929">
		<FirstName>Billy</FirstName>
		<MiddleName>Jean</MiddleName>
		<LastName>IsNotMyLover</LastName>
		<Email>rrr111@psu.edu</Email>
		<ShibbolethAuthentication/>
		<Item xlink:type="simple" xlink:href="/login/service/v4/User/USERNAME:rrr111"/>
	</User>
	<User username="GGG222" dmu:userId="56789" enabled="false">
		<FirstName>General</FirstName>
		<LastName>Tso</LastName>
		<Email>GGG222@psu.edu</Email>
		<ShibbolethAuthentication/>
		<Item xlink:type="simple" xlink:href="/login/service/v4/User/USERNAME:GGG222"/>
	</User>
	<User username="jjj333" dmu:userId="234567" PSUID="999999939">
		<FirstName>Micheal</FirstName>
		<LastName>Jackson</LastName>
		<Email>jjj333@psu.edu</Email>
		<ShibbolethAuthentication/>
		<Item xlink:type="simple" xlink:href="/login/service/v4/User/USERNAME:jjj333"/>
	</User>
     </Users>'
  end

  let(:userid_obj) {ImportUserids.allocate}

  describe "#call" do
    it "should convert the xml to a hash and
        should populate database with userid info" do

      userid_obj.response = xml
      Faculty.create(access_id: 'zzz333')
      Faculty.create(access_id: 'yyy444')
      Faculty.create(access_id: 'rrr111')
      Faculty.create(access_id: 'jjj333')
      userid_obj.call
      expect(UserNum.all.count).to eq(4)
      expect(UserNum.find_by(id_number: 123456).faculty.access_id).to eq('zzz333')
      expect(UserNum.find_by(id_number: 234567).faculty.access_id).to eq('jjj333')
      expect(UserNum.find_by(id_number: 56789)).to eq(nil)
    end
  end

end
