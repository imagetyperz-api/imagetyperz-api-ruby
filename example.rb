#!/usr/bin/ruby

# Imagetypers API test
load "lib/imagetyperzapi.rb"

def test_api
  access_token = "access_token_here"
  ita = ImageTyperzAPI.new(access_token)

  # legacy way, will get deprecated at some point
  #ita.set_user_and_password('your_username', 'your_password')

  # check account balance
  # ---------------------------------------------------
  balance = ita.account_balance          # get balance
  puts "Account balance: #{balance}"   # print balance

  # solve classic captcha
  # ----------------------
  puts "Solving captcha ... "
  captcha_text = ita.solve_captcha'captcha.jpg'
  puts "Captcha text: #{captcha_text}"

  # recaptcha
  # ---------------------------------------------------
  # submit to server and get the id

  d = {}
  d['page_url'] = 'page_url_here'
  d['sitekey'] = 'sitekey_here'
  # d['type'] = 3    # optional, defaults to 1
  # d['v3_min_score'] = 0.3          # min score to target when solving v3 - optional
  # d['v3_action'] = 'homepage'      # action to use when solving v3 - optional
  # d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
  # d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
  captcha_id = ita.submit_recaptcha d

  puts "Waiting for recaptcha to be solved ..."
  while ita.in_progress captcha_id  # while it"s still in progress
    sleep 10    # sleep for 10 seconds
  end

  # get the response and print it
  recaptcha_response = ita.retrieve_recaptcha captcha_id    # retrieve response
  puts "Recaptcha response: #{recaptcha_response}"

  # Other examples
  # ---------------------------------------------------
  # ita = ImageTyperzAPI.new(access_token, 1234, 60)    # with affiliate id, and 60 seconds timeout
  #puts ita.recaptcha_id
  #puts ita.recaptcha_response
  #puts ita.was_proxy_used captcha_id        # tells if proxy submitted (if any) was used or not, and if not used, reason
  #puts ita.set_captcha_bad "123"            # set captcha bad
  #puts ita.captcha_id                      # get last solved captcha id
  #puts ita.captcha_text                    # get last solved captcha text
  #puts ita.recaptcha_id                    # get last solved recaptcha id
  #puts ita.recaptcha_response              # get last solved recaptcha response
end

def main
  begin
    test_api
  rescue => details
    puts "[!] Error occured: #{details}"
  end
end

main
