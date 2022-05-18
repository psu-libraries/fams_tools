require 'rails_helper'

describe VerifyPostPrint do
  let(:verify_post_print) { described_class.new }

  describe "#is_pdf_file_valid" do
    context 'when filename is bad' do
      it 'returns a :status of false' do
        verify1 = verify_post_print.send(:is_pdf_file_valid, 'test-PROOF.pdf')
        expect(verify1[:status]).to eq false
        expect(verify1[:message]).to eq "Bad file name"
        verify2 = verify_post_print.send(:is_pdf_file_valid, 'test-in+press.pdf')
        expect(verify2[:status]).to eq false
        expect(verify2[:status]).to eq false
        expect(verify2[:message]).to eq "Bad file name"
      end
    end

    context 'when Subject is Journal Pre-proof' do
      let(:pdf) do
        { info: { Subject: "Journal Pre-proof" } }
      end
      it 'returns a :status of false' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Bad Subject"
      end
    end

    context 'when Creator is Elsevier' do
      let(:pdf) do
        { info: { Creator: "Elsevier" } }
      end
      it 'returns a :status of false' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when Creator is Arbortext Advanced Print Publisher' do
      let(:pdf) do
        { info: { Creator: "Arbortext Advanced Print Publisher" } }
      end
      it 'returns a :status of false' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when Creator is Springer' do
      let(:pdf) do
        { info: { Creator: "Springer" } }
      end
      it 'returns a :status of false' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when Creator is Appligent' do
      let(:pdf) do
        { info: { Creator: "Appligent" } }
      end
      it 'returns a :status of false' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when Creator is Microsoft' do
      let(:pdf) do
        { info: { Creator: "Microsoft" } }
      end
      it 'returns a :status of true' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq true
        expect(verify[:message]).to eq "Found a good creator"
      end
    end

    context 'when Creator is LaTeX' do
      let(:pdf) do
        { info: { Creator: "LaTeX" } }
      end
      it 'returns a :status of true' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq true
        expect(verify[:message]).to eq "Found a good creator"
      end
    end

    context 'when Creator is Preview' do
      let(:pdf) do
        { info: { Creator: "Preview" } }
      end
      it 'returns a :status of true' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq true
        expect(verify[:message]).to eq "Found a good creator"
      end
    end

    context 'when Creator is TeX' do
      let(:pdf) do
        { info: { Creator: "TeX" } }
      end
      it 'returns a :status of true' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq true
        expect(verify[:message]).to eq "Found a good creator"
      end
    end

    context 'when nothing to parse' do
      let(:pdf) do
        { info: {} }
      end

      it 'returns a :status of false' do
        allow(PDF::Reader).to receive(:open).with('test.pdf').and_yield(double('PDF::Reader', pdf))
        verify = verify_post_print.send(:is_pdf_file_valid, 'test.pdf')
        expect(verify[:status]).to eq nil
        expect(verify[:message]).to eq ""
      end
    end
  end

  describe "#is_exif_valid" do
    context 'when journal_article_version is "AM"' do
      let(:exif_hash) do
        { journal_article_version: "AM" }
      end

      it 'returns a :status of true' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq true
        expect(verify[:message]).to eq "accepted manuscript"
      end
    end

    context 'when journal_article_version is "P"' do
      let(:exif_hash) do
        { journal_article_version: "P" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "proof"
      end
    end

    context 'when journal_article_version is "VOR"' do
      let(:exif_hash) do
        { journal_article_version: "VOR" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "version of record"
      end
    end

    context 'when subject contains "downloaded from"' do
      let(:exif_hash) do
        { subject: "downloaded from acbd1234" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "subject contains downloaded from"
      end
    end

    context 'when creator is "Elsevier"' do
      let(:exif_hash) do
        { creator: "Elsevier" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator is "Arbortext Advanced Print Publisher"' do
      let(:exif_hash) do
        { creator: "Arbortext Advanced Print Publisher" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator is "Springer"' do
      let(:exif_hash) do
        { creator: "Springer" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator is "Appligent"' do
      let(:exif_hash) do
        { creator: "Appligent" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator_tool is "Appligent"' do
      let(:exif_hash) do
        { creator_tool: "Appligent" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator_tool is "Elsevier"' do
      let(:exif_hash) do
        { creator_tool: "Elsevier" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator_tool is "Arbortext Advanced Print Publisher"' do
      let(:exif_hash) do
        { creator_tool: "Arbortext Advanced Print Publisher" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when creator_tool is "Springer"' do
      let(:exif_hash) do
        { creator_tool: "Springer" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad creator"
      end
    end

    context 'when producer is "iText"' do
      let(:exif_hash) do
        { producer: "iText" }
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq false
        expect(verify[:message]).to eq "Found a bad producer"
      end
    end

    context 'when nothing to parse' do
      let(:exif_hash) do
        {}
      end

      it 'returns a :status of false' do
        allow(Exiftool).to receive_message_chain(:new, :to_hash).and_return(exif_hash)
        verify = verify_post_print.send(:is_exif_valid, 'test.pdf')
        expect(verify[:status]).to eq nil
        expect(verify[:message]).to eq ''
      end
    end
  end
end
