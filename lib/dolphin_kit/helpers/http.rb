require 'net/http'

module DolphinKit
  module HTTP
    module_function

    def get(url, params: {})
      uri = URI(url)
      uri.query = URI.encode_www_form(params) unless params.empty?
      Net::HTTP.get_response(uri)
    end

    def post(url, form: {})
      uri = URI(url)
      Net::HTTP.post_form(uri, **form)
    end
  end
end
