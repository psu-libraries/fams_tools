require 'rails_helper'

describe PostPrintAnalyzer do
  let(:analyzer) { described_class.new(CSV.new("POST_FILE_1_DOC\nabc123/intellcont/test.pdf", headers: :first_row)) }
  before do
    clear_directory
    allow(analyzer).to receive(:f_name).and_return('post_print_list.csv')
    allow(analyzer).to receive(:f_path).and_return("#{Rails.root}/spec/fixtures/post_prints/post_print_list.csv")
    allow(analyzer).to receive(:post_prints_directory).and_return("#{Rails.root}/spec/fixtures/post_prints")
    allow(analyzer).to receive(:analysis_directory).and_return("#{Rails.root}/spec/fixtures/post_prints")
    allow(analyzer).to receive(:clear_pp_files).and_return(true)
    allow(analyzer).to receive(:clear_last_analysis).and_return(true)
    allow_any_instance_of(VerifyPostPrint).to receive(:verify).and_return(true)
  end

  after do
    clear_directory
  end

  describe 'analyze' do
    context 'when no error is returned from system call' do
      it 'does not write to error to File' do
        allow_any_instance_of(Kernel).to receive(:system).and_return(true)
        analyzer.analyze
        expect(File.read("#{Rails.root}/spec/fixtures/post_prints/errors.txt")).to eq ""
      end
    end

    context 'when an error is returned from system call' do
      it 'writes error to File' do
        allow_any_instance_of(Kernel).to receive(:system).and_return(false)
        analyzer.analyze
        expect(File.read("#{Rails.root}/spec/fixtures/post_prints/errors.txt")).to eq "abc123/intellcont/test.pdf"
      end
    end
  end
end

def clear_directory
  Dir.foreach("#{Rails.root}/spec/fixtures/post_prints") do |f|
    fn = File.join("#{Rails.root}/spec/fixtures/post_prints", f)
    File.delete(fn) if File.exist?(fn) && f != '.' && f != '..'
  end
end
