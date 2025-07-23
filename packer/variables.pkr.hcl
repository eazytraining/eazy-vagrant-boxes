# variables.pkr.hcl
variable "version" {
  type        = string
  description = "Version of the box"
  default     = "1.0.0"
}
##
variable "box_name" {
  type        = string
  description = "Name of the Vagrant box"
  default     = "ubuntu2204"
}

variable "vagrant_cloud_username" {
  type        = string
  description = "Vagrant Cloud username"
  default     = ""
}

variable "vagrant_cloud_token" {
  type        = string
  description = "Vagrant Cloud API token"
  default     = ""
  sensitive   = true
}

variable "cpus" {
  type        = number
  description = "Number of CPUs"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Amount of memory in MB"
  default     = 2048
}

variable "disk_size" {
  type        = number
  description = "Disk size in MB"
  default     = 65536
}

variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "vagrant"
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  default     = "vagrant"
}

variable "headless" {
  type        = bool
  description = "Run without GUI"
  default     = true
}