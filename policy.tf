data "template_file" "policydata" {
    template = "${file("policy.json")}"
    vars = {
        bucket_name = "${aws_s3_bucket.bucketname.bucket}"
    }
}
output "rendering" {
  value = "${data.template_file.policydata.rendered}"
}