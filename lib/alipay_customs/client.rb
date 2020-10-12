# frozen_string_literal: true

require "httparty"

module AlipayCustoms
  # A Ruby wrapper class for Weixin customs API
  class Client
    include HTTParty
    BASE_URIS = {
      production: "https://intlmapi.alipay.com/gateway.do",
      test: "https://mapi.alipaydev.com/gateway.do"
    }.freeze

    attr_accessor :partner, :key, :customs_place, :merchant_customs_code, :merchant_customs_name

    # Initializes a new Client object
    #
    # @param options [Hash]
    # @return [WxCustoms::Client]
    def initialize(options = {})
      options.each do |key, val|
        instance_variable_set("@#{key}", val)
      end
      yield(self) if block_given?

      @sign_type ||= AlipayCustoms::Sign::SIGN_TYPE_MD5
      @env ||= :test
      @base_uri = BASE_URIS[@env.to_sym]
    end

    # Transmit information to customs
    #
    # @see https://global.alipay.com/docs/ac/global/acquire_customs
    # @params params [Hash]
    # @return [HTTParty::Response]
    def acquire_customs(params)
      body = {
        service: "alipay.acquire.customs",
        partner: partner,
        customs_place: customs_place,
        merchant_customs_code: merchant_customs_code,
        merchant_customs_name: merchant_customs_name
      }.merge(common_params, params)

      invoke_remote(@base_uri, body.merge({ sign: AlipayCustoms::Sign.generate(body, key) }))
    end

    # Query the custom declaration status
    #
    # @see https://global.alipay.com/docs/ac/global/customs_query
    # @params params [Hash]
    # @return [HTTParty::Response]
    def customs_query(params)
      body = {
        service: "alipay.overseas.acquire.customs.query",
        partner: partner
      }.merge(common_params, params)

      invoke_remote(@base_uri, body.merge({ sign: AlipayCustoms::Sign.generate(body, key) }))
    end

    private

    def common_params
      {
        _input_charset: "UTF-8",
        sigh_type: @sign_type
      }
    end

    def merchant_params
      {
        partner: partner,
        customs_place: customs_place,
        merchant_customs_code: merchant_customs_code,
        merchant_customs_name: merchant_customs_name
      }
    end

    def invoke_remote(url, body, options = { headers: {} })
      self.class.post(url, headers: options[:headers], body: body)
    end
  end
end
