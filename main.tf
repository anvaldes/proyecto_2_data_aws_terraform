provider "aws" {
  region = var.region
}

resource "aws_s3_bucket_object" "pyspark_script" {
  bucket = var.s3_bucket
  key    = "scripts/job.py"
  source = "${path.module}/scripts/job.py"
  etag   = filemd5("${path.module}/scripts/job.py")
}

resource "aws_emr_cluster" "pyspark_cluster" {
  name          = "pyspark-cluster"
  release_label = "emr-6.15.0"
  applications  = ["Spark"]
  service_role  = var.emr_service_role
  autoscaling_role = var.emr_autoscaling_role

  ec2_attributes {
    key_name                          = var.key_name
    instance_profile                  = var.ec2_instance_profile
  }

  master_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 1
  }

  step {
    name              = "Run PySpark Job"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = [
        "spark-submit",
        "--deploy-mode", "cluster",
        "--master", "yarn",
        "s3://${var.s3_bucket}/scripts/job.py"
      ]
    }
  }

  lifecycle {
    ignore_changes = [step] # permite re-aplicar sin duplicar steps
  }

  termination_protection = false
  visible_to_all_users   = true
  keep_job_flow_alive_when_no_steps = false
}

output "cluster_id" {
  value = aws_emr_cluster.pyspark_cluster.id
}