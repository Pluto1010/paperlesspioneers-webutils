class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  class << self
    def http_basic_authenticate_with_sha256(options = {})
      # @see https://github.com/rails/rails/blob/51a2f7bb67cd58a1f5e999ee60f4eb97730f7f35/actionpack/lib/action_controller/metal/http_authentication.rb#L69
      # @see http://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic.html
      before_action(options.except(:name, :password_hash, :realm)) do
        authenticate_or_request_with_http_basic(options[:realm] || "Application") do |name, password|
          # This comparison uses & so that it doesn't short circuit and
          # uses `variable_size_secure_compare` so that length information
          # isn't leaked.
          ActiveSupport::SecurityUtils.variable_size_secure_compare(name, options[:name]) &
            ActiveSupport::SecurityUtils.variable_size_secure_compare(Digest::SHA512.hexdigest(password + name), options[:password_hash])
        end
      end
    end
  end

  http_basic_authenticate_with_sha256 name: (ENV['HTTP_BASIC_AUTH_USERNAME'] || "user"), password_hash: (ENV['HTTP_BASIC_AUTH_PASSWORD_HASH_SHA512'] || Digest::SHA512.hexdigest("password"+"user"))
end
