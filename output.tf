output "ip_privado" {
  value = "${module.ec2-instance.private_ip}"
}
