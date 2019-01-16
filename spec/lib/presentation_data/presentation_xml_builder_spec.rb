require 'rails_helper'
require 'presentation_data/presentation_xml_builder'

RSpec.describe PresentationXMLBuilder do

  before do
    faculty = Faculty.create(access_id: 'abc123')

    presentation1 = Presentation.create(faculty: faculty,
                                        title: 'Test Presentation 1',
                                        dty_date: '2016',
                                        name: 'Name 1',
                                        org: 'Organization 1',
                                        location: 'Location 1')

    PresentationContributor.create(presentation: presentation1,
                                   f_name: 'Arnold',
                                   m_name: 'Bernie',
                                   l_name: 'Curt')
  end

  let(:presentation_xml_builder_obj) {PresentationXMLBuilder.new}

  describe '#batched_xmls' do
    it 'should return a properly formatted xml of PRESENT records' do
      expect(presentation_xml_builder_obj.batched_xmls).to eq([

      ])
    end
  end
end

