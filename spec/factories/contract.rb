FactoryBot.define do
  factory :contract do
    sequence(:osp_key)
    title { 'Title' }
    status { 'Awarded' }
    submitted { '2015-02-01' }
    awarded { '2015-03-01' }
    requested { 1000 }
    funded { 500 }
    total_anticipated { 10_000 }
    start_date { '2015-02-01' }
    end_date { '2017-02-01' }
    grant_contract { 'Grant' }
    base_agreement { 'XYZ123' }
    notfunded { '' }
    sequence(:sponsor) { |n| Sponsor.create sponsor_name: "Name#{n}" }
    effort_academic { 0.15 }
    effort_summer { 0.16 }
    effort_calendar { 0.17 }
  end
end
