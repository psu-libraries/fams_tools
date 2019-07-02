FactoryBot.define do
  factory :work do
    author { [['Jim', '', 'Bob']] }
    title { 'Test' }
    journal { nil }
    volume { 1 }
    edition { 2 }
    pages { '1-2' }
    date { 2001 }
    item { nil }
    booktitle { nil }
    container { 'Test Journal' }
    contype { 'Journal Article' }
    genre { 'article-journal' }
    doi { nil }
    editor { [['Frank', 'Zappa']] }
    institution { 'PSU' }
    isbn { nil }
    location { 'State College' }
    note { 'Some note' }
    publisher { nil }
    retrieved { nil }
    tech { nil }
    translator { nil }
    unknown { nil }
    url { nil }
    username { 'test123' }
  end
end
