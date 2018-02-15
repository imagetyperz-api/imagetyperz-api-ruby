#!/usr/bin/ruby

# Imagetypers API test
load "lib/imagetyperzapi.rb"

def test_api
  access_token = "your_access_token_here"
  ita = ImageTyperzAPI.new(access_token, 1, 1)

  # legacy way, will get deprecated at some point
  ita.set_user_and_password('testingfor', 'testingfor')

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
  captcha_id = ita.submit_recaptcha "page_url_here","sitekey_here"
  puts "Waiting for recaptcha to be solved ..."
  while ita.in_progress captcha_id  # while it"s still in progress
    sleep 10    # sleep for 10 seconds
  end

  # get the response and print it
  recaptcha_response = ita.retrieve_recaptcha captcha_id    # retrieve response
  puts "Recaptcha response: #{recaptcha_response}"

  # Other examples
  # ---------------------------------------------------
  # ita = ImageTyperzAPI.new(access_token, 1234)    # with affiliate id
  #puts ita.recaptcha_id
  #puts ita.recaptcha_response
  #ita.set_recaptcha_proxy"123.45.67.78:8080"
  #ita.set_recaptcha_proxy"123.45.67.78:8080:user:password"		# proxy with auth
  #print ita.set_captcha_bad"123"    # set captcha bad
end

def main
  begin
    test_api()
  rescue => details
    puts "[!] Error occured: #{details}"
  end
end

main
