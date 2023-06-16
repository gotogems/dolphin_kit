module DolphinKit
  class YoudaoService
    BASE_URL = 'https://fanyi.youdao.com'

    def initialize(keyfrom: nil, key: nil, endpoint: nil)
      @endpoint = "#{BASE_URL}/openapi.do"
      @keyfrom, @key = keyfrom, key
    end

    def call(text:)
      response = HTTP.get(@endpoint, params: build_params(text))
      result = JSON.parse(response.body)

      if (code = result['errorCode'].to_i) > 0
        @failure = FAILURES[code]
      else
        @failure = nil
      end

      result
    end

    private

    def build_params(value)
      {
        type: 'data',
        doctype: 'json',
        version: '1.1',
        keyfrom: @keyfrom,
        key: @key,
        q: value
      }
    end

    FAILURES = {
      20 => '要翻译的文本过长',
      30 => '无法进行有效的翻译',
      40 => '不支持的语言类型',
      50 => '无效的 Key',
      60 => '无词典结果，仅在获取词典结果生效'
    }
  end
end
