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
  captcha_id = ita.submit_image(image_path = 'captcha.jpg')
  # with optional image parameters
  # captcha_id = ita.solve_captcha(image_path = 'captcha.jpg', is_case_sensitive = true, is_math = true, is_phrase = true, digits_only = false, letters_only = true, min_length = 2, max_length = 5)
  captcha_text = ita.retrieve_response captcha_id
  puts "Response: #{captcha_text}"
end

def main
  begin
    test_api
  rescue => details
    puts "[!] Error occured: #{details}"
  end
end

main
