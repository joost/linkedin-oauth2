module LinkedIn
  module Helpers

    module Request
      API_PATH = '/v1'

      protected

        def get(path, options={})
          begin
            response = access_token.get("#{API_PATH}#{path}", options)
          rescue ::OAuth2::Error => e
            raise_errors(e.response)
          end
          response.body
        end

        def post(path, options={})
          response = access_token.post("#{API_PATH}#{path}", options)
          raise_errors(response)
          response
        end

        def put(path, options={})
          response = access_token.put("#{API_PATH}#{path}", options)
          raise_errors(response)
          response
        end

        def delete(path, options={})
          response = access_token.delete("#{API_PATH}#{path}", options)
          raise_errors(response)
          response
        end

      private

        def raise_errors(response)
          data = Mash.from_xml(response.body)

          case response.status.to_i
          when 401
            raise LinkedIn::Errors::UnauthorizedError.new(data), "(#{data.status}): #{data.message}"
          when 400
            raise LinkedIn::Errors::GeneralError.new(data), "(#{data.status}): #{data.message}"
          when 403
            raise LinkedIn::Errors::AccessDeniedError.new(data), "(#{data.status}): #{data.message}"
          when 404
            raise LinkedIn::Errors::NotFoundError, "(#{data.status}): #{data.message}"
          when 500
            raise LinkedIn::Errors::InformLinkedInError, "LinkedIn had an internal error. Please let them know in the forum. (#{data.status}): #{data.message}"
          when 502..503
            raise LinkedIn::Errors::UnavailableError, "(#{data.status}): #{data.message}"
          end
        end


        # Stolen from Rack::Util.build_query
        def to_query(params)
          params.map { |k, v|
            if v.class == Array
              to_query(v.map { |x| [k, x] })
            else
              v.nil? ? escape(k) : "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
            end
          }.join("&")
        end

        def to_uri(path, options)
          uri = URI.parse(path)

          if options && options != {}
            uri.query = to_query(options)
          end
          uri.to_s
        end
    end

  end
end
