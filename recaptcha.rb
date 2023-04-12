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
  d['page_url'] = 'https://your-site.com'
  d['sitekey'] = '7LrGJmcUABBAALFtIb_FxC0LXm_GwOLyJAfbbUCL'

  # reCAPTCHA type(s) - optional, defaults to 1
  # ---------------------------------------------
  # 1 - v2
  # 2 - invisible
  # 3 - v3
  # 4 - enterprise v2
  # 5 - enterprise v3
  #
  # d['type'] = 1    # optional, defaults to 1
  #
  # d['domain'] = 'www.google.com'    # used in loading reCAPTCHA interface, default: www.google.com (alternative: recaptcha.net) - optional
  # d['v3_min_score'] = 0.3          # min score to target when solving v3 - optional
  # d['v3_action'] = 'homepage'      # action to use when solving v3 - optional
  # d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
  # d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
  # d['data-s'] = 'recaptcha data-s value' # optional
  # d['cookie_input'] = 'a=b;c=d' # optional
  captcha_id = ita.submit_recaptcha d
  response = nil
  while response == nil
    sleep 10
    response = ita.retrieve_response captcha_id
  end
  puts "Response: #{response}"

  # other examples
  # ita = ImageTyperzAPI.new(access_token, '123') # initialize library with affiliateID
  # initialize library with affiliateID and requests timeout
  # ita = ImageTyperzAPI.new(access_token, '123', 60000)
  # ita.set_captcha_bad(123)  # set captcha bad using ID
end

def main
  begin
    test_api
  rescue => details
    puts "[!] Error occurred: #{details}"
  end
end

main
