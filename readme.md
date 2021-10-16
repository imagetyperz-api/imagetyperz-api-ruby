imagetyperz-api-ruby - Imagetyperz API wrapper
=========================================

imagetyperzapi is a super easy to use bypass captcha API wrapper for imagetyperz.com captcha service

## Installation
    gem "imagetyperzapi", :git => "git://github.com/imagetyperz-api/imagetyperz-api-ruby.git"
    
or
    
    git clone https://github.com/imagetyperz-api/imagetyperz-api-ruby

## Usage

Simply require the module, set the auth details and start using the captcha service:

``` ruby
load "lib/imagetyperzapi.rb"
```
Set access_token for authentication:

``` ruby
# grab token from https://imagetyperz.com
access_token = "your_access_token"
ita = ImageTyperzAPI.new(access_token)
```
Once you've set your authentication details, you can start using the API.

**Get balance**

``` ruby
balance = ita.account_balance          # get balance
puts "Account balance: #{balance}"     # print balance
```

## Solving
For solving a captcha, it's a two step process:
- **submit captcha** details - returns an ID
- use ID to check it's progress - and **get solution** when solved.

Each captcha type has it's own submission method.

For getting the response, same method is used for all types.


### Image captcha

``` ruby
captcha_id = ita.submit_image(image_path = 'captcha.jpg')
```
(with optional parameters)
```ruby
captcha_id = ita.solve_captcha(image_path = 'captcha.jpg', is_case_sensitive = true, is_math = true, is_phrase = true, digits_only = false, letters_only = true, min_length = 2, max_length = 5)
```
ID is used to retrieve solution when solved.

**Observation**
It works with URL instead of image file too.

### reCAPTCHA

For recaptcha submission there are two things that are required.
- page_url (**required**)
- site_key (**required**)
- type (optional, defaults to 1 if not given)
    - `1` - v2
    - `2` - invisible
    - `3` - v3
    - `4` - enterprise v2
    - `5` - enterprise v3
- v3_min_score - minimum score to target for v3 recaptcha `- optional`
- v3_action - action parameter to use for v3 recaptcha `- optional`
- proxy - proxy to use when solving recaptcha, eg. `12.34.56.78:1234` or `12.34.56.78:1234:user:password` `- optional`
- user_agent - useragent to use when solve recaptcha `- optional` 
- data-s - extra parameter used in solving recaptcha `- optional`
- cookie_input - cookies used in solving reCAPTCHA - `- optional`

``` ruby
d = {}
d['page_url'] = 'https://your-site.com'
d['sitekey'] = '7LrGJmcUABBAALFtIb_FxC0LXm_GwOLyJAfbbUCL'
# d['type'] = 3    # optional, defaults to 1
# d['v3_min_score'] = 0.3          # min score to target when solving v3 - optional
# d['v3_action'] = 'homepage'      # action to use when solving v3 - optional
# d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
# d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
# d['data-s'] = 'recaptcha data-s value' # optional
# d['cookie_input'] = 'a=b;c=d'  # optional
captcha_id = ita.submit_recaptcha d
```
ID will be used to retrieve the g-response, once workers have 
completed the captcha. This takes somewhere between 10-80 seconds. 

Check **Retrieve response** 

### GeeTest

GeeTest is a captcha that requires 3 parameters to be solved:
- domain
- challenge
- gt
- api_server (optional)

The response of this captcha after completion are 3 codes:
- challenge
- validate
- seccode

**Important**
This captcha requires a **unique** challenge to be sent along with each captcha.

```ruby
d = {}
d['domain'] = 'https://your-site.com'
d['challenge'] = 'eea8d7d1bd1a933d72a9eda8af6d15d3'
d['gt'] = '1a761081b1114c388092c8e2fd7f58bc'
d['api_server'] = 'api.geetest.com' # geetest domain - optional
# d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
# d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
captcha_id = ita.submit_geetest d
```

Optionally, you can send proxy and user_agent along.

### hCaptcha

Requires pageurl and sitekey

```ruby
d = {}
d['pageurl'] = 'https://your-site.com'
d['sitekey'] = '1c7062c7-cae6-4e12-96fb-303fbec7fe4f'
# d['invisible'] = '1'             # if invisible hcaptcha - optional
# d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
# d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
captcha_id = ita.submit_hcaptcha d
```

### Capy

Requires pageurl and sitekey

```ruby
d = {}
d['pageurl'] = 'https://your-site.com'
d['sitekey'] = 'Fme6hZLjuCRMMC3uh15F52D3uNms5c'
# d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
# d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
captcha_id = ita.submit_capy d
```

### Tiktok

Requires pageurl and cookie_input

```ruby
d = {}
d['pageurl'] = 'tiktok.com'
# make sure `s_v_web_id` cookie is present
d['cookie_input'] = 's_v_web_id:verify_kd6243o_fd449FX_FDGG_1x8E_8NiQ_fgrg9FEIJ3f;tt_webid:612465623570154;tt_webid_v2:7679206562717014313;SLARDAR_WEB_ID:d0314f-ce16-5e16-a066-71f19df1545f;'
# d['proxy'] = '126.45.34.53:123'  # - HTTP proxy - optional
# d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
captcha_id = ita.submit_tiktok d
```

### FunCaptcha

Requires pageurl, sitekey and surl (source URL)

```ruby
d = {}
d['pageurl'] = 'https://your-site.com'
d['sitekey'] = '11111111-1111-1111-1111-111111111111'
d['surl'] = 'https://api.arkoselabs.com'
# d['data'] = '{"a":"b"}'   # optional, extra funcaptcha data in JSON format
# d['proxy'] = '126.45.34.53:123'  # optional - HTTP proxy - optional
# d['user_agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0' # optional
captcha_id = ita.submit_funcaptcha d
```

## Retrieve response

Regardless of the captcha type (and method) used in submission of the captcha, this method is used
right after to check for it's solving status and also get the response once solved.

It requires one parameter, that's the **captcha ID** gathered from first step.

```ruby
response = ita.retrieve_response(captcha_id)
```

```ruby
# get a captcha_id first
captcha_id = ita.submit_recaptcha d
response = nil
while response == nil
  sleep 10
  response = ita.retrieve_response captcha_id
end
puts "Response: #{response}"
```
The response is a JSON object that looks like this:
```json
{
  "CaptchaId": 176707908, 
  "Response": "03AGdBq24PBCbwiDRaS_MJ7Z...mYXMPiDwWUyEOsYpo97CZ3tVmWzrB", 
  "Cookie_OutPut": "", 
  "Proxy_reason": "", 
  "Recaptcha score": 0.0, 
  "Status": "Solved"
}
```

## Other methods/variables

**Affiliate id**

The constructor accepts a 2nd parameter, as the affiliate id. 
``` ruby
ita = ImageTyperzAPI.new(access_token, '123')
```

**Requests timeout**

As a 3rd parameter in the constructor, you can specify a timeout for the requests (in seconds)
``` ruby
ita = ImageTyperzAPI.new(access_token, '123', 60000)  # sets timeout to 60 seconds
```

**Set captcha bad**

When a captcha was solved wrong by our workers, you can notify the server with it's ID,
so we know something went wrong.

``` ruby
ita.set_captcha_bad(captcha_id)
```

## Examples
Check root folder for examples, for each type of captcha.

## License
API library is licensed under the MIT License

## More information
More details about the server-side API can be found [here](http://imagetyperz.com)


<sup><sub>captcha, bypasscaptcha, decaptcher, decaptcha, 2captcha, deathbycaptcha, anticaptcha, 
bypassrecaptchav2, bypassnocaptcharecaptcha, bypassinvisiblerecaptcha, captchaservicesforrecaptchav2, 
recaptchav2captchasolver, googlerecaptchasolver, recaptchasolverruby, recaptchabypassscript</sup></sub>

