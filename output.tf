output "tags" {
    description = "printing the resource tags"
    type = maps(string)
    value = [ for tags in var.tagging : lower(tags) ]
}

output "publicip" {
  description = "printing the public ip"
  vaule = "${aws_instance.linux_instance.public_ip}"
}

output "privateip" {
  description = "printing the private ip"
  vaule = "${aws_instance.linux_instance.private_ip}"
}