imagetyperz-api-ruby - Imagetyperz API wrapper
=========================================

imagetyperzapi is a super easy to use bypass captcha API wrapper for imagetyperz.com captcha service

## Installation
    gem "imagetyperzapi", :git => "git://github.com/imagetyperz-api/imagetyperz-api-ruby.git"

or
    
    git clone https://github.com/imagetyperz-api/imagetyperz-api-ruby
     

## How to use?

Simply require the module, set the auth details and start using the captcha service:

``` ruby
load "lib/imagetyperzapi.rb"
```
Set access_token or username and password (legacy) for authentication

``` ruby
access_token = 'access_token_here'
# get access token from: http://www.imagetyperz.com/Forms/ClientHome.aspx
ita = ImageTyperzAPI.new(access_token)
```
``` ruby
# legacy way, will get deprecated at some point
ita.set_user_password('your_username', 'your_password')
```
Once you've set your authentication details, you can start using the API

**Get balance**

``` ruby
balance = ita.account_balance              
puts "Account balance: #{balance}"         
```

## Image captcha

**Submit image captcha**

``` ruby
captcha_text = ita.solve_captcha('captcha.jpg')
```
**Works with URL instead of captcha image in case of access key authentication**
``` ruby
ita.solve_captcha('http://abc.com/your_captcha.jpg')   
```

## reCAPTCHA

### Submit recaptcha details

For recaptcha submission there are two things that are required.
- page_url
- site_key
- type - can be one of this 3 values: `1` - normal, `2` - invisible, `3` - v3 (it's optional, defaults to `1`)
- v3_min_score - minimum score to target for v3 recaptcha `- optional`
- v3_action - action parameter to use for v3 recaptcha `- optional`
- proxy - proxy to use when solving recaptcha, eg. `12.34.56.78:1234` or `12.34.56.78:1234:user:password` `- optional`
- user_agent - useragent to use when solve recaptcha `- optional` 
``` ruby
d = {}
d['page_url'] = 'page_url_here'
d['sitekey'] = 'sitekey_here'
d['type'] = 3    # optional, defaults to 1
d['v3_min_score'] = 0.3          # min score to target when solving v3 - optional
d['v3_action'] = 'homepage'      # action to use when solving v3 - optional
d['proxy'] = '126.45.34.53:123'  # - optional
d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
captcha_id = ita.submit_recaptcha d
```
This method returns a captchaID. This ID will be used next, to retrieve the g-response, once workers have 
completed the captcha. This takes somewhere between 10-80 seconds.

### Retrieve recaptcha response

Once you have the captchaID, you check for it's progress, and later on retrieve the gresponse.

The ***in_progress(captcha_id)*** method will tell you if captcha is still being decoded by workers.
Once it's no longer in progress, you can retrieve the gresponse with ***retrieve_recaptcha(captcha_id)***  

``` ruby
while ita.in_progress(captcha_id)  # while it"s still in progress
    sleep 10    # sleep for 10 seconds
end

gresponse = ita.retrieve_recaptcha(captcha_id)
```

## GeeTest

GeeTest is a captcha that requires 3 parameters to be solved:
- domain
- challenge
- gt

The response of this captcha after completion are 3 codes:
- challenge
- validate
- seccode

### Submit GeeTest
```ruby
geetest_params = {}
geetest_params["domain"] = "domain_here"
geetest_params["challenge"] = "challenge_here"
geetest_params["gt"] = "gt_here"
# optional params
#geetest_params["proxy"] = "126.45.34.53:345"    # or 126.45.34.53:123:joe:password
#geetest_params["user_agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0"    # optional
geetest_params = geetest_challenge
captcha_id = ita.submit_geetest geetest_params
```
Just like reCAPTCHA, you'll receive a captchaID.
Using the ID, you'll be able to retrieve 3 codes after completion.

Optionally, you can send proxy and user_agent along.

### Retrieve GeeTest codes
```ruby
puts "Geetest captcha ID: #{captcha_id}"
puts "Waiting for geetest to be solved..."
while ita.in_progress captcha_id
  sleep 1
end
geetest_response = ita.retrieve_geetest(captcha_id)
puts geetest_response
```

Response will look like this: `{'challenge': '...', 'validate': '...', 'seccode': '...'}`



## Other methods/variables

**Affiliate id**

The constructor accepts a 2nd parameter, as the affiliate id. 
``` ruby
ita = ImageTyperzAPI.new(access_token, 1234)
```

**Requests timeout**

As a 3rd parameter in the constructor, you can specify a timeout for the requests (in seconds)
``` ruby
ita = ImageTyperzAPI.new(access_token, 123, 60)  # sets timeout to 60 seconds
```

**Get details of proxy for recaptcha**

In case you submitted the recaptcha with proxy, you can check the status of the proxy, if it was used or not,
and if not, what the reason was with the following:

``` ruby
puts ita.was_proxy_used captcha_id        # tells if proxy submitted (if any) was used or not, and if not used, reason
```

**Set captcha bad**

When a captcha was solved wrong by our workers, you can notify the server with it's ID,
so we know something went wrong.

``` ruby
ita.set_captcha_bad(captcha_id)
```

## Examples
Check example.rb

## License
API library is licensed under the MIT License

## More information
More details about the server-side API can be found [here](http://imagetyperz.com)


<sup><sub>captcha, bypasscaptcha, decaptcher, decaptcha, 2captcha, deathbycaptcha, anticaptcha, 
bypassrecaptchav2, bypassnocaptcharecaptcha, bypassinvisiblerecaptcha, captchaservicesforrecaptchav2, 
recaptchav2captchasolver, googlerecaptchasolver, recaptchasolverpython, recaptchabypassscript</sup></sub>
