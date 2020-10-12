# frozen_string_literal: true

require "digest/md5"

module AlipayCustoms
  # :nodoc:
  module Sign
    SIGN_TYPE_MD5 = "MD5"

    # Generate signature of parameters
    #
    # @see https://global.alipay.com/docs/ac/customs/signature_verfication
    # @raise [ArgumentError] Error raised when `sign_type` is not supported.
    # @return [String] The sign string.
    # @param params [Hash] Parameters to be signed.
    # @param sign_type [String] Signature type, only support "MD5" now.
    def self.generate(params, key, sign_type = SIGN_TYPE_MD5)
      sorted_params = params.delete_if { |k, v| %w[sign sign_type].include?(k.to_s) || v.to_s.empty? }.sort.map do |k, v|
        "#{k}=#{v}"
      end.compact.join("&")

      # Only support MD5 signature type now. Will support SHA1, SHA256, HMAC later.
      # doc: https://pay.weixin.qq.com/wiki/doc/api/external/declarecustom.php?chapter=4_1
      case sign_type
      when SIGN_TYPE_MD5
        Digest::MD5.hexdigest(sorted_params + key.to_s)
      else
        raise ArgumentError, "non-supported signature type: #{sign_type}"
      end
    end

    # Verify signature of parameters
    #
    # @see https://global.alipay.com/docs/ac/customs/signature_verfication
    # @raise [ArgumentError] Error raised when `sign_type` is not supported.
    # @return [String] The sign string.
    # @param target [String] target to be verified.
    # @param params [Hash] Parameters to be signed.
    # @param sign_type [String] Signature type, only support "MD5" now.
    def self.verify(target, params, key, sign_type = SIGN_TYPE_MD5)
      sorted_params = params.delete_if { |k, v| %w[sign sign_type].include?(k.to_s) || v.to_s.empty? }.sort.map do |k, v|
        "#{k}=#{v}"
      end.compact.join("&")

      # Only support MD5 signature type now. Will support SHA1, SHA256, HMAC later.
      # doc: https://pay.weixin.qq.com/wiki/doc/api/external/declarecustom.php?chapter=4_1
      case sign_type
      when SIGN_TYPE_MD5
        target == Digest::MD5.hexdigest(sorted_params + key.to_s)
      else
        raise ArgumentError, "non-supported signature type: #{sign_type}"
      end
    end
  end
end
