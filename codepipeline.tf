# codepipeline.tf
resource "aws_codebuild_project" "nginx_build" {
  name         = "nginx-build"
  service_role = "arn:aws:iam::381492000626:role/codebuild-service-role"  # Example ARN, replace with your actual IAM role ARN

  artifacts {
    type = "NO_ARTIFACTS"  # Example, change according to your project requirements
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"  # Example, change according to your project requirements
    image                       = "aws/codebuild/standard:4.0"  # Example, change according to your project requirements
    type                        = "LINUX_CONTAINER"  # Example, change according to your project requirements
    image_pull_credentials_type = "CODEBUILD"  # Example, change according to your project requirements
  }

  source {
    type            = "NO_SOURCE"  # Example, change according to your project requirements
    buildspec       = file("${path.module}/buildspec.yaml")  # Example, if using buildspec file, specify its location
  }
}

resource "aws_iam_role" "pipeline_role" {
  name               = "pipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  description = "IAM role for CodePipeline"

  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }

  # Attach the AWS managed policy named "AdministratorAccess"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    # Add more managed policy ARNs if needed
  ]

}



resource "aws_codepipeline" "nginx_pipeline" {
  name     = "nginx-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = "static-web-hosting-cloudfront-bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket    = "your-source-bucket"
        S3ObjectKey = "your-source-object"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.nginx_build.name
      }
    }
  }
}
