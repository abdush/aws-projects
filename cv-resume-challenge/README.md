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
