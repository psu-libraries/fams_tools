module CommitteeData
  class EtdaImporter
    class Endpoint
      attr_reader :partner

      PARTNERS = %i[graduate honors millennium_scholars sset].freeze

      def initialize(partner)
        @partner = partner
      end

      def self.each(&)
        PARTNERS.each do |partner|
          yield new(partner)
        end
      end

      def url
        ENV.fetch("#{@partner.to_s.upcase}_API_URL", 'http://localhost:3000')
      end

      def api_token
        ENV.fetch("#{@partner.to_s.upcase}_API_TOKEN", 'abc123')
      end
    end
  end
end
