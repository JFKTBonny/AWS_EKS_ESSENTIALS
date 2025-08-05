# This resource defines an EC2 launch template to be used for provisioning instances (e.g., with a Node Group or Auto Scaling Group).
resource "aws_launch_template" "launch_template" {
  name = "ip-prefix-launch-template"  # Name of the launch template

  # Define block device mappings, including the root volume size
  block_device_mappings {
    device_name = "/dev/sdf"  # Device name for the attached volume
    ebs {
      volume_size = 50        # Size of the EBS volume in GiB
    }
  }

  ebs_optimized = true  # Enables EBS-optimized instance for higher performance

  # Configure instance metadata service (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"         # Enables IMDS
    http_tokens                 = "required"        # Requires IMDSv2 token usage
    http_put_response_hop_limit = 2                 # Limits how far instance metadata requests can travel
    instance_metadata_tags      = "enabled"         # Allows access to instance tags via metadata
  }

  # Network settings for the instance
  network_interfaces {
    associate_public_ip_address = false  # Disables auto-association of public IP
  }

  # User data script to bootstrap the instance, encoded in base64
  user_data = filebase64("${path.module}/user-data.sh")

  # Tagging configuration applied to EC2 instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      name = "ip-prefix-custom-launch-template"  # Tag to identify instances from this launch template
    }
  }
}
