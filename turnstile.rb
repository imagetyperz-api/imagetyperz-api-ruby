#!/usr/bin/ruby

# Imagetypers API test
load "lib/imagetyperzapi.rb"

def test_api
  # grab token from https://imagetyperz.com
  access_token = "access_token_here"
  ita = ImageTyperzAPI.new(access_token)

  # check account balance
  balance = ita.account_balance          # get balance
  puts "Account balance: #{balance}"     # print balance

  # submit image captcha, and check for solution
  puts "Waiting for captcha to be solved..."
  d = {}
  d['pageurl'] = 'https://your-site.com'
  d['sitekey'] = '0x4ABBBBAABrfvW5vKbx11FZ'

  # optional parameters, specific to loading of turnstile interface
  # d['domain'] = 'challenges.cloudflare.com'   # domain used in loading turnstile interface, default: challenges.cloudflare.com - optional
  # d['action'] = 'homepage'                    # used in loading turnstile interface, similar to reCAPTCHA - optional
  # d['cdata'] = 'your cdata information'       # used in loading turnstile interface - optional

  # d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
  # d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
  captcha_id = ita.submit_turnstile d
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
    puts "[!] Error occurred: #{details}"
  end
end

main
