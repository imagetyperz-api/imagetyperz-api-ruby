#!/usr/bin/ruby

# Imagetypers API test
load "lib/imagetyperzapi.rb"

def test_api
  access_token = "your_access_token"
  ita = ImageTyperzAPI.new(access_token)

  # legacy way, will get deprecated at some point
  # ita.set_user_and_password('your_username', 'your_password')

  # check account balance
  # ---------------------------------------------------
  balance = ita.account_balance          # get balance
  puts "Account balance: #{balance}"   # print balance

  # solve classic captcha
  # ----------------------
  puts "Solving captcha ... "
  captcha_text = ita.solve_captcha(image_path = 'captcha.jpg')
  # with optional image parameters
  #captcha_text = ita.solve_captcha(image_path = 'captcha.jpg', is_case_sensitive = true, is_math = true, is_phrase = true, digits_only = false, letters_only = true, min_length = 2, max_length = 5)
  puts "Captcha text: #{captcha_text}"

  # recaptcha
  # ---------------------------------------------------
  # submit to server and get the id

  d = {}
  d['page_url'] = 'page_url_here'    # adding --capy to the end of this, will make captcha be a capy captcha instead of reCAPTCHA
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

  # GeeTest captcha
  # ---------------
  # geetest_params = {}
  # geetest_params["domain"] = "domain_here"
  # geetest_params["challenge"] = "challenge_here"
  # geetest_params["gt"] = "gt_here"
  # # optional params
  # #geetest_params["proxy"] = "126.45.34.53:345"    # or 126.45.34.53:123:joe:password
  # #geetest_params["user_agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0"    # optional
  # captcha_id = ita.submit_geetest geetest_params
  # puts "Geetest captcha ID: #{captcha_id}"
  # puts "Waiting for geetest to be solved..."
  # while ita.in_progress captcha_id
  #   sleep 1
  # end
  # geetest_response = ita.retrieve_geetest(captcha_id)
  # puts geetest_response

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
