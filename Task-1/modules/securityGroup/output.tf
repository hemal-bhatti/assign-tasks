output "alb_sg_id" { value = aws_security_group.alb.id }
output "jenkins_master_sg_id" { value = aws_security_group.jenkins_master.id }
output "jenkins_agent_sg_id" { value = aws_security_group.jenkins_agent.id }
output "bastion_sg_id" { value = aws_security_group.bastion.id } # <-- ADD THIS LINE
output "instance_profile_name" { value = aws_iam_instance_profile.jenkins_profile.name }