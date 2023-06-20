require 'openssl'
require 'base64'

module DolphinKit
  class QCloudService
    BASE_URL = 'https://tmt.tencentcloudapi.com'

    def initialize(app_id: nil, app_key: nil, endpoint: nil)
      @secret_id, @secret_key = app_id, app_key
      @endpoint = endpoint || BASE_URL
    end

    def call(text:, source: 'auto', target: nil)
      target ||= (LANGUAGES - [source.to_sym]).first
      params = { Source: source, Target: target }.merge(build_params(text))
      params[:Signature] = sign(@secret_key, build_data(params))

      response = HTTP.get(@endpoint, params: params)
      result = JSON.parse(response.body)['Response']

      @failure = result.dig('Error', 'Message')
      result
    end

    private

    def build_params(value)
      {
        Action: 'TextTranslate',
        Region: 'ap-guangzhou',
        Version: '2018-03-21',
        ProjectId: '0',
        SignatureMethod: 'HmacSHA256',
        Timestamp: Time.now.to_i.to_s,
        Nonce: rand(1000..9999).to_s,
        SecretId: @secret_id,
        SourceText: value
      }
    end

    def build_data(params = {})
      result = params
        .keys
        .sort
        .map { |key| "#{key}=#{params[key]}" }
        .join('&')

      "GET#{URI(BASE_URL).host}/?#{result}"
    end

    def sign(key, data, algo = 'SHA256')
      Base64.encode64(OpenSSL::HMAC.digest(algo, key, data))
    end

    LANGUAGES = %i{
      en zh ja ko es de fr vi th
      ar hi id it ms pt ru tr zh-TW
    }
  end
end
