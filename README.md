# To launch Web application using aws cloud and terraform end to end automation
Task :To create/launch Application using Terraform


If You want to put your static files of website on the s3 bucket and want to attach that s3 bucket cloud front, then perform  part 1 in the start and then part 2

If You don't want to put your static files of website on the s3 bucket, then perform  part 2 only

here i have given the process of part1 and part2 but you have to run only the files which i given name as part_1 and part_2

Part 1:
1. Create S3 bucket,
2. Upload the static file like images, videos into the s3 bucket and change the permission to public readable.
3. Create a Cloudfront using s3 bucket(which contains images) 
4. Use the Cloudfront URL and update in your source code (Like image src="url")


part 2:
1. Create the key in aws console and download it.
2. Create security group which allow the port 80.
2. Launch EC2 instance.
3. While launching EC2 instance use the key and security group which you have created in step 1-2.
4. Launch EBS Volume Then attach that volume to EC2 instance
5. Connect to the EC2 instance.
6. Install httpd and git, Format the attached EBS volume or create partition
7. Mount the /var/www/html folder to one of partition of EBS volume, Remove the primary files which are in /var/www/html folder/directory
8. Download The Code to the /var/www/html/ using github
9. start the httpd server

