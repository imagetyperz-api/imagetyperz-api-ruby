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

**Submit image captcha**

``` ruby
captcha_text = ita.solve_captcha('captcha.jpg')
```
**Works with URL instead of captcha image in case of access key authentication**
``` ruby
ita.solve_captcha('http://abc.com/your_captcha.jpg')   
```
**Submit recaptcha details**

For recaptcha submission there are two things that are required.
- page_url
- site_key
``` ruby
captcha_id = ita.submit_recaptcha(page_url, sitekey)        # submit captcha first, to get ID
```
This method returns a captchaID. This ID will be used next, to retrieve the g-response, once workers have 
completed the captcha. This takes somewhere between 10-80 seconds.

**Retrieve captcha response**

Once you have the captchaID, you check for it's progress, and later on retrieve the gresponse.

The ***in_progress(captcha_id)*** method will tell you if captcha is still being decoded by workers.
Once it's no longer in progress, you can retrieve the gresponse with ***retrieve_recaptcha(captcha_id)***  

``` ruby
while ita.in_progress(captcha_id)  # while it"s still in progress
    sleep 10    # sleep for 10 seconds
end

gresponse = ita.retrieve_recaptcha(captcha_id)
```

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

**Set proxy for recaptcha submission**

If you set a proxy, it will be used for recaptcha submission. The method to use for setting the proxy is **set_recaptcha_proxy**
When this is set, the workers will complete the captcha using the provided proxy/IP.
``` ruby
ita.set_recaptcha_proxy("123.45.67.78:8080")
```
Proxy with authentication is also supported
``` ruby
ita.set_recaptcha_proxy("123.45.67.78:8080:user:password")
```
We currently support HTTP proxies.

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
