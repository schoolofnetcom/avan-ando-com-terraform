variable "access_key" {
    default = "AKIAJEHMCWOQIRDFIK2A"}

variable "secret_key" {
    default = "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"}
variable "region" {
  default = "us-east-1"
}

variable "cidrs" {
  default = ["177.35.84.198/32","181.223.12.87/32"]
}

variable "amis" {
    type = "map"
    default = {
        "us-east-1" = "ami-059eeca93cf09eebd"
        "us-east-2" = "ami-0782e9ee97725263d"
    }
  
}

