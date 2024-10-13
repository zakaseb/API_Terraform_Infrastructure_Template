# Create ECR repository
resource "aws_ecr_repository" "callsign" {
  name = "callsign"
}
