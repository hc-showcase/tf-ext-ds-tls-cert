data "external" "tls_certificate" {
  program = ["bash", "${path.root}/read_certificate.sh"]

  query = {
    url = "google.com"
  }
}

output "serial_number" {
  value = data.external.tls_certificate.result.serial_number
}
output "not_before" {
  value = data.external.tls_certificate.result.not_before
}
output "cert" {
  value = data.external.tls_certificate.result.cert
}
output "label" {
  value = data.external.tls_certificate.result.label
}

