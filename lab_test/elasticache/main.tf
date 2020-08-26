# resource "aws_elasticache_security_group" "lab-test-elasticache" {
#   name                 = "lab-test-elasticache"
#   security_group_names = var.sg_ids_name
# }

resource "aws_elasticache_subnet_group" "lab-test-moodle" {
  name       = "lab-test-moodle"
  subnet_ids = var.subnet_ids_security_name
}

resource "aws_elasticache_cluster" "lab-test-elasticache" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.lab-test-moodle.name
  #security_group_ids   = aws_elasticache_subnet_group.lab-test-moodle.subnet_ids
  security_group_ids    = var.sg_ids

  depends_on = [var.depends]
}