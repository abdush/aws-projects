# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region  = "eu-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "terraform"
}

# Additional provider configuration for west coast region; resources can
# reference this as `aws.us_west`.
provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}
