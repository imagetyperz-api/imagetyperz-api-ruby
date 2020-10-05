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
  d['pageurl'] = 'tiktok.com'
  # make sure `s_v_web_id` cookie is present
  d['cookie_input'] = 's_v_web_id:verify_kd6243o_fd449FX_FDGG_1x8E_8NiQ_fgrg9FEIJ3f;tt_webid:612465623570154;tt_webid_v2:7679206562717014313;SLARDAR_WEB_ID:d0314f-ce16-5e16-a066-71f19df1545f;'
  # d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
  # d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
  captcha_id = ita.submit_tiktok d
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
