store Jenkins build artifect in s3 bucket

Prerequisites in AWSCreate an S3 Bucket: Set up a bucket (e.g., my-jenkins-artifacts-bucket) in your preferred AWS region.Create an IAM Policy: Create a policy with s3:PutObject and s3:GetObject permissions for that bucket.Generate Credentials: Create an IAM User with that policy and save the Access Key ID and Secret Access Key. Alternatively, if Jenkins runs on an AWS EC2 instance, attach an IAM Role to the instance instead.


Step 1: Install the Pipeline AWS PluginOpen your Jenkins Dashboard.Go to Manage Jenkins > Plugins.Select the Available Plugins tab.Search for Pipeline AWS and install it.Restart Jenkins if prompted.


Step 2: Save AWS Credentials in Jenkins(Skip this step if your Jenkins server uses an EC2 IAM Instance Role)Go to Manage Jenkins > Credentials.Select System > Global credentials (unrestricted).Click Add Credentials.Set Kind to AWS Credentials.Set the ID to a recognizable name (e.g., aws-s3-creds).Input your Access Key ID and Secret Access Key.Click Create.


Step 3: Add the S3 Upload Code to Your JenkinsfileIn your Jenkins Pipeline script, wrap the s3Upload step inside a withAWS block to authenticate and push the files.For Declarative Pipelines:

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // Example step that generates an artifact
                sh 'mkdir -p target && echo "build success" > target/app.jar'
            }
        }
        stage('Upload to S3') {
            steps {
                // Authenticate using the saved Jenkins credential ID
                withAWS(credentials: 'aws-s3-creds', region: 'us-east-1') {
                    
                    // Upload the specific file to your target bucket path
                    s3Upload(
                        bucket: 'my-jenkins-artifacts-bucket',
                        file: 'target/app.jar',
                        path: "builds/${env.JOB_NAME}/${env.BUILD_NUMBER}/app.jar"
                    )
                }
            }
        }
    }
}