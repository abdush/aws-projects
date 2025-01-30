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