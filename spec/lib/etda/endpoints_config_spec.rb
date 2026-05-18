require 'rails_helper'
require 'etda/endpoints_config'

RSpec.describe Etda::EndpointsConfig do
  describe '.all_endpoints' do
    it 'returns a hash of all 4 endpoints' do
      endpoints = Etda::EndpointsConfig.all_endpoints
      expect(endpoints.keys).to contain_exactly(:etda, :honors, :millennium_scholars, :sset)
    end

    it 'each endpoint has url and api_token' do
      endpoints = Etda::EndpointsConfig.all_endpoints
      endpoints.each_value do |endpoint|
        expect(endpoint).to have_key(:url)
        expect(endpoint).to have_key(:api_token)
      end
    end

    it 'uses ETDA_API_URL as default for :etda endpoint' do
      with_env('ETDA_API_URL', 'https://etda-url.test') do
        endpoints = Etda::EndpointsConfig.all_endpoints
        expect(endpoints[:etda][:url]).to eq('https://etda-url.test')
      end
    end

    it 'uses environment variables for all 4 endpoints' do
      with_env('ETDA_API_URL', 'https://etda.test', 'ETDA_API_TOKEN', 'token1') do
        with_env('HONORS_API_URL', 'https://honors.test', 'HONORS_API_TOKEN', 'token2') do
          with_env('MILLENNIUM_SCHOLARS_API_URL', 'https://ms.test', 'MILLENNIUM_SCHOLARS_API_TOKEN', 'token3') do
            with_env('SSET_API_URL', 'https://sset.test', 'SSET_API_TOKEN', 'token4') do
              endpoints = Etda::EndpointsConfig.all_endpoints

              expect(endpoints[:etda]).to eq({ url: 'https://etda.test', api_token: 'token1' })
              expect(endpoints[:honors]).to eq({ url: 'https://honors.test', api_token: 'token2' })
              expect(endpoints[:millennium_scholars]).to eq({ url: 'https://ms.test', api_token: 'token3' })
              expect(endpoints[:sset]).to eq({ url: 'https://sset.test', api_token: 'token4' })
            end
          end
        end
      end
    end

    it 'has default localhost values for development' do
      endpoints = Etda::EndpointsConfig.all_endpoints
      expect(endpoints[:etda][:url]).to include('localhost') if ENV['ETDA_API_URL'].blank?
    end
  end

  describe '.endpoint' do
    it 'returns configuration for a specific endpoint' do
      config = Etda::EndpointsConfig.endpoint(:etda)
      expect(config).to have_key(:url)
      expect(config).to have_key(:api_token)
    end

    it 'raises error for unknown endpoint' do
      expect { Etda::EndpointsConfig.endpoint(:unknown) }.to raise_error(Etda::EndpointsConfig::UnknownEndpointError)
    end
  end

  private

  def with_env(key, value, *pairs)
    original = {}
    [key, value, *pairs].each_slice(2) do |k, v|
      original[k] = ENV[k]
      ENV[k] = v
    end

    yield

    original.each { |k, v| ENV[k] = v }
  end
end
