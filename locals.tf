locals{
    common_tags = {
        Project     = var.project_name
        Environment = var.environment
        Terrafrom = "true"
    }
    common_name_suffix = "${var.project_name}-${var.environment}"
}