resource "aws_key_pair" "base_kp" {
  key_name   = "base_kp"
  public_key = file(var.public_key_path)
}