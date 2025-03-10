# cv-resume-challenge
https://cloudresumechallenge.dev/docs/the-challenge/aws/

## setup

1. create aws account (with access credentials)
   1. access & secret keys (not recommended anymore by AWS)
   2. todo: use aws sso, or short-lived tokens, use tools like aws-vault to store/manage credentials
2. install aws cli
3. install terraform (test simple demo)

## website template

some free template options to download:
https://startbootstrap.com/themes/portfolio-resume?showPro=false
https://html5up.net/

## website s3 bucket
1. region for the bucket is from the provider section (you can add multiple providers with alias)
2. specify bucket name & website config (index.html) - bucket name need to match domain name??
3. website config section will enable S3 static website hosting
4. create variables and outputs tf file to provide those and capture the website endpoint / domain

make note of the website_endpoint output. For example: *ahussein-resume.com.s3-website.eu-west-2.amazonaws.com*

### make it public
If you try to access this one the browser, it will give 403 forbidden because we have not enabled public access on the bucket.

Using tf aws_s3_bucket_public_access_block resource to disable the block all public access setting. However, this alone will not allow public access (website still returns 403). We need to add bucket policy and allow public read.

After adding bucket policy which GetObject for all, now we get 404 when accessing url. This is because we didn't upload our index.html file yet.

### Upload sample home page:

`aws-vault exec terraform -- aws s3 cp .\website\index.html s3://ahussein-resume.com/ --content-type "text/html"`

TODO: 
If you don't want to disable block public access settings for your bucket but you still want your website to be public, you can create a Amazon CloudFront distribution to serve your static website

## CloudFront distribution

create CF OAC and CF distribution to access s3 bucket. We can block public access to bucket and update bucket policy to only allow access from OAC

required config are for 
- origin (s3 bucket id, domain name, and OAC id) - before you have to create OAC resource with type s3.
- default cache behaviour: this references AWS managed cache optimized policy
- viewer certificate: default certificate provided by AWS which supports HTTPS connections using CF domain name (doesn't support custom domains - for that we need to create certificate in ACM and reference here)

We update the bucket policy to allow read access only from CF service matching our created distribution arn
The deployment for CF takes some time | 5mins.

Now if we test access from s3 endpoint we should get 403. We can only access through CF domain (ex. https://d18mhgp0szxckk.cloudfront.net/)

## Register domain name

You can either use Route53 or another domain registrar to buy a new domain. In this case I have used namecheap to register domain ahussein.pro for about $4 for first year.
Next is to create Route53 hosted zone with the same domain name and then add a record of type A (Alias) which points the domain name to our cloudfront domain name. Once this is done we need to get the route53 name servers for our hosted zone and update those in our namecheap DNS service.

### Update Cloudfront alias domain
We need to update settings for CF aliases to point to the custom domain name (and any other alternatives ex. resume.mydomain.com).
To enable HTTPS from viewers, we can request public certificate from ACM. 

**Important notes:**
1. The certicate need to be requested in us-east-1 region as per [aws docs]([https://](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-aws-region))
2. Certificate DNS validation. CNAME records need to be added to Route53 and then wait for validatoin. This can be done automatically by terraform
3. The certificate must cover the alternate domain name in the SAN field of the certificate. " This means the SAN field must contain an exact match for the alternate domain name, or contain a wildcard at the same level of the alternate domain name that you’re adding."
4. we also need to add Route53 record for the subdomain. Besides, we add AAAA records for IPv6 if enabled in cloudfront.

*Question:* First terraform apply created the ACM certificate in eu-west-2 region. After changing the region (using new provider alias for that region), and running terraform apply the new ACM certificate is created in the new region, but old one still exists. How can it be deleted from terraform?

When everything is setup correctly, we should be able to access our website from both root domain and the subdomain below (browser will redirect to https).
https://ahussein.pro/
https://resume.ahussein.pro/

## Upload website template:

Find suitable [template]([https://](https://startbootstrap.com/theme/resume)) and update site content.
The whole template can be uploaded to s3 bucket with command:

`aws-vault exec terraform -- aws s3 cp .\website\ s3://ahussein-resume.com/ --recursive`


## Lambda function
create the python source file for the lambda function and define a data zip archive resource in TF which will create the zip payload for the lambda. Define iam assume role policy and iam role and assign to the lambda function resource defined in TF. Other configuration includes the filename, functionname, runtime, handler (entrypoint).

Invoke lambda from CLI:
`aws-vault exec terraform -- aws lambda invoke --function-name=$(terraform output -raw function_name) response.json
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}

cat .\response.json
{"statusCode": 200, "headers": {"Content-Type": "application/json"}, "body": "{\"count\": 1234}"}
`

Todo: log groups (cloudwatch) for lambda and API gateway

## API Gateway
configuration defines 5 API Gateway resources:

1. api resource: defines a name for the API Gateway and sets its protocol to HTTP.
2. stage: sets up application stages for the API Gateway - such as "Test", "Staging", and "Production". access logging can be enabled here.
3. integration: configures the API Gateway to use your Lambda function.
4. route: maps an HTTP request (GET /visitor-count) to a target, in this case your Lambda function intergration.
5. lambda permission: gives API Gateway permission to invoke your Lambda function.

The API Gateway stage will publish your API to a URL managed by AWS which is captured in TF output (stage base url).

`curl "$(terraform output -raw visitor_stage_url)/visitor-count"
{"count": 1234}

 curl "$(terraform output -raw visitor_api_url)/visitor-count"  
{"message":"Not Found"}
`

## Javascript API call
add AJAX call to the API gateway and add html element to display the visitor counter.
remember to upload the changed files to s3 bucket.

`aws-vault exec terraform -- aws s3 cp .\website\ s3://ahussein-resume.com/ --recursive`

### CORS issue:
If you try to access API from website, you will get CORS error
`
Access to fetch at 'https://rbj9x7ls55.execute-api.eu-west-2.amazonaws.com/dev/visitor-count' from origin 'null' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.
`

We need to configure CORS in our API gateway. With the new HTTP API Gateway v2, we don't need to define CORS response headers in the lambda respone, the API config is all what is needed. Configure allow_origins from our custom domain and allow_methods for GET

test call

`
curl -v -X GET "$(terraform output -raw visitor_stage_url)/visitor-count"  -H 'Origin:https://resume.ahussein.pro' -H 'Access-Control-Request-Method: GET'
Note: Unnecessary use of -X or --request, GET is already inferred.
* Uses proxy env variable no_proxy == '192.168.99.100'
* Host rbj9x7ls55.execute-api.eu-west-2.amazonaws.com:443 was resolved.
* IPv6: (none)
* IPv4: 3.11.59.99, 18.130.27.41
*   Trying 3.11.59.99:443...
* schannel: disabled automatic use of client certificate
* ALPN: curl offers http/1.1
* ALPN: server accepted http/1.1
* Connected to rbj9x7ls55.execute-api.eu-west-2.amazonaws.com (3.11.59.99) port 443
* using HTTP/1.x
> GET /dev/visitor-count HTTP/1.1
> Host: rbj9x7ls55.execute-api.eu-west-2.amazonaws.com
> User-Agent: curl/8.10.1
> Accept: */*
> Origin:https://resume.ahussein.pro
> Access-Control-Request-Method: GET
>
* schannel: remote party requests renegotiation
* schannel: renegotiating SSL/TLS connection
* schannel: SSL/TLS connection renegotiated
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Mon, 17 Feb 2025 22:47:37 GMT
< Content-Type: application/json
< Content-Length: 15
< Connection: keep-alive
< access-control-allow-origin: https://resume.ahussein.pro
< Apigw-Requestid: GJplficCrPEEP0Q=
<
{"count": 1234}* Connection #0 to host rbj9x7ls55.execute-api.eu-west-2.amazonaws.com left intact
`

Now access from website should work!

## DynamoDB
define resource for table with has key (id) and type as string. No need to define the count column in table definition. It can be automatically added from lambda function (Number type auto inferred). For cost-efficiency, use pay-per-request (on-demand) pricing.
Update lambda function to fetch from table using unique key (id) column. Increment counter & update into db. 
Now the lambda function need to get permission to read/write from/to dynamodb. This is done using iam role (assume role) with attached policy which has Get/Update/Put Item actions on our table.

## lambda 500 error

`TypeError: Object of type Decimal is not JSON serializable`
[solution]([https://](https://repost.aws/articles/ARRJPOEgrUSIuLebbcoETaAg/how-to-use-the-python-json-module-when-decoding-dynamodb-items)) here is to use default=int for json dumps method for the response