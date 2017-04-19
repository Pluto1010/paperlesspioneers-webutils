require 'net/http'
require 'csv'

class UsersController < ApplicationController
  def index
    users = []
    begin
      users += new_users = fetch_users(users.size)
    end while new_users.size > 0

    csv_options = {
      col_sep: ";",
      encoding: "utf-8",
      quote_char: '"',
      force_quotes: true,
      headers: ['emailAddress', 'username', 'displayName'],
      write_headers: true
    }
    csv_result = CSV.generate(csv_options) do |csv|
      users.each do |user|
        csv << [user[:emailAddress], user[:username], user[:displayName]]
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_result, filename: "users.csv" }
    end
  end

  private
  def fetch_users(skip = 0)
    uri = URI("https://paperless.ryver.com/api/1/odata.svc/users?$select=emailAddress,username,displayName&$filter=newUser+eq+false&$skip=#{skip}&$inlinecount=allpages")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth ENV['RYVER_USERNAME'], ENV['RYVER_PASSWORD']

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }

    foo = JSON.parse(res.body, symbolize_names: true)
    foo[:d][:results]
  end
end
