//connection with aws

provider "aws"{ 
    region     = "ap-south-1"
    profile    = "ssw"    //Enter your profile name which set at cli login
  }

//connection with aws end
//create s3 bucket

resource "aws_s3_bucket" "mys3bktssw"{
  bucket = "terrabkt"
  acl    = "private"
  region = "ap-south-1"
  force_destroy= true

  tags = {
    Name        = "terrabkt"
  }
}

//create s3 bucket end
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Some comment"   // enter here a unique name instead of "some comment"
}

locals{
  s3_origin_id = "${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path}"
}

//creat cloud front

resource "aws_cloudfront_distribution" "mycldfrntssw"{
  origin{
    domain_name =  aws_s3_bucket.mys3bktssw.bucket_regional_domain_name
    origin_id   =  local.s3_origin_id

    s3_origin_config{
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some_comment"
  default_root_object = "index.html"

  default_cache_behavior{
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values{
      query_string = false

      cookies{
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior{
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values{
      query_string = false
      headers      = ["Origin"]

      cookies{
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior{
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values{
      query_string = false

      cookies{
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions{
    geo_restriction{
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags ={
    Environment = "production"
  }

  viewer_certificate{
    cloudfront_default_certificate = true
  }
}


resource "null_resource" "download_IP"{

    depends_on = [
    aws_cloudfront_distribution.mycldfrntssw,
    ]
    provisioner "local-exec"{
          command = "echo ${aws_cloudfront_distribution.mycldfrntssw.domain_name} > your_static_files_domain.text "   //you will get your ip address in "yourdomain.txt" file in directory where you run this code    
      }
  }
//creat cloud front end
//to upload files on bucket
  resource "null_resource" "upload_files"{

    depends_on = [
    null_resource.download_IP,
    ]
    provisioner "local-exec"{
          command = "aws s3 sync C:/Users/SSRJ/Desktop/img s3://terrabkt --acl public-read"   //change the path for the folder you want to upload just like all inside "ssw" folder is uploading here
      }
  }
//to upload files on bucket end
//to block public acces by updating policy of bucket

resource "aws_s3_bucket_public_access_block" "bpa"{

depends_on = [
    null_resource.upload_files,
    ]
	bucket=aws_s3_bucket.mys3bktssw.id
	block_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
	#rember above we gave acl private
}

//to block public acces by updating policy of bucket end
