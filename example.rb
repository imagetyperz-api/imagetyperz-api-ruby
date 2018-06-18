#!/usr/bin/ruby

# Imagetypers API test
load "lib/imagetyperzapi.rb"

def test_api
  access_token = "your_access_token_here"
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
  page_url = 'your_page_url'
  sitekey = 'your_sitekey'

  captcha_id = ita.submit_recaptcha page_url, sitekey
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
  #ita.set_recaptcha_proxy"123.45.67.78:8080"
  #ita.set_recaptcha_proxy"123.45.67.78:8080:user:password"		# proxy with auth
  #puts ita.was_proxy_used captcha_id        # tells if proxy submitted (if any) was used or not, and if not used, reason
  #print ita.set_captcha_bad"123"            # set captcha bad
  #print ita.captcha_id                      # get last solved captcha id
  #print ita.captcha_text                    # get last solved captcha text
  #print ita.recaptcha_id                    # get last solved recaptcha id
  #print ita.recaptcha_response              # get last solved recaptcha response
end

def main
  begin
    test_api()
  rescue => details
    puts "[!] Error occured: #{details}"
  end
end

main
