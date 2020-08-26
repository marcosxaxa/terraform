variable "cluster_id" {}
variable "node_type" {}
variable "num_cache_nodes" {}
variable "subnet_ids_security_name" {type = list(string)}
variable "sg_ids" {type = list(string)}
variable "depends" {type = list(string)}
