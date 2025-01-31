# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region  = "eu-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "terraform"
}

# Additional provider configuration for west coast region; resources can
# reference this as `aws.us-west-2`.
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "terraform"
}

# Create an ACM certificate for HTTPS support in us-east-1 (required for CloudFront)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "terraform"
}
