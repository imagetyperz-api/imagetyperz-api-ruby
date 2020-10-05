#!/usr/bin/ruby

# Imagetypers API test
load "lib/imagetyperzapi.rb"

def test_api
  # grab token from https://imagetyperz.com
  access_token = "your_access_token"
  ita = ImageTyperzAPI.new(access_token)

  # check account balance
  balance = ita.account_balance          # get balance
  puts "Account balance: #{balance}"     # print balance

  # submit image captcha, and check for solution
  puts "Waiting for captcha to be solved..."
  d = {}
  d['pageurl'] = 'https://your-site.com'
  d['sitekey'] = '1c7062c7-cae6-4e12-96fb-303fbec7fe4f'
  # d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
  # d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
  captcha_id = ita.submit_hcaptcha d
  response = nil
  while response == nil
    sleep 10
    response = ita.retrieve_response captcha_id
  end
  puts "Response: #{response}"
end

def main
  begin
    test_api
  rescue => details
    puts "[!] Error occured: #{details}"
  end
end

main
