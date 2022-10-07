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

  # task parameters
  d = {
    'template_name': 'Login test page',
    'pageurl': 'https://imagetyperz.net/automation/login',
    'variables': {"username": 'abc', "password": 'paZZW0rd'},
    # 'proxy': '126.45.34.53:345',   # or 126.45.34.53:123:joe:password
    # 'user_agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0',    # optional
  }


  captcha_id = ita.submit_task d
  # submit image captcha, and check for solution
  puts "Waiting for captcha to be solved..."

  # send pushVariable - update of variable while task is running (e.g 2FA code)
  # ------------------------------------------------------------------------------
  # ita.task_push_variables captcha_id, {"twofactor_code": code}

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
