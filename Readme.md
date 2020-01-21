# devspace-nginx-s3

Docker image and devspace configuration for kubernetes service which
serves files from private S3 repository.

# Usage

See [Devspace docs](https://devspace.cloud/docs/introduction) for
instructions on deployment to kubernetes, development, and composition
with other services.

The service depends on an already existing kubernetes secret in
the namespace, which has the following keys:

* s3_bucket: s3 bucket to serve files from
* prefix: stem of path to prepend to requests (expected to end in "/")
* aws_key: aws access key id
* aws_secret: aws secret access key

To limit security ramifications, we recommend creating an IAM role
and access key to serve this particular bucket/path. Also, 
[sealed secrets](https://github.com/bitnami-labs/sealed-secrets)
are useful to limit access to the secret.
