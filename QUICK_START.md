# 🚀 Quick Start Guide

Get your microservice infrastructure up and running in 5 steps!

## ✅ Pre-flight Checklist

Before starting, ensure you have:
- [ ] AWS Account with admin access
- [ ] AWS Access Key ID and Secret Access Key
- [ ] EC2 Key Pair created (download the .pem file)
- [ ] GitHub account
- [ ] This code in a GitHub repository

---

## Step 1: Add GitHub Secrets (2 minutes)

1. Go to your GitHub repository
2. Click `Settings` → `Secrets and variables` → `Actions` → `New repository secret`
3. Add these three secrets:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | AWS Console → IAM → Users → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | Same as above |
| `SSH_PRIVATE_KEY` | Contents of your .pem file | Open your .pem file and copy ALL text |

**Important:** For `SSH_PRIVATE_KEY`, copy the entire file including:
```
-----BEGIN RSA PRIVATE KEY-----
... (all the content) ...
-----END RSA PRIVATE KEY-----
```

---

## Step 2: Update Configuration (3 minutes)

### 2.1 Create a Unique Bucket Name
Think of a globally unique name for your S3 bucket:
- Must be lowercase
- Can contain numbers and hyphens
- Must be globally unique across all AWS
- Example: `mycompany-terraform-state-2024`

### 2.2 Update These Files

**File: `terraform/backend-setup/variables.tf`**
```hcl
variable "state_bucket_name" {
  default = "YOUR-UNIQUE-BUCKET-NAME"  # 👈 Change this
}
```

**File: `terraform/infrastructure/backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket = "YOUR-UNIQUE-BUCKET-NAME"  # 👈 Change this (same as above)
    key    = "microservice/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}
```

**File: `.github/workflows/deploy.yml`**
```yaml
env:
  AWS_REGION: eu-north-1
  TF_VERSION: 1.6.0
  STATE_BUCKET: YOUR-UNIQUE-BUCKET-NAME  # 👈 Change this (same as above)
```

**File: `terraform/infrastructure/terraform.tfvars`**
```hcl
key_name = "YOUR-KEY-PAIR-NAME"  # 👈 Change this to your AWS key pair name
```

---

## Step 3: Setup Backend (1 minute)

This only needs to be done ONCE.

1. Push your changes to GitHub
2. Go to `Actions` tab in GitHub
3. Click `Deploy Microservice Infrastructure`
4. Click `Run workflow` (top right)
5. Select **`setup-backend`** from the dropdown
6. Click the green `Run workflow` button

Wait 1-2 minutes. You'll see:
- ✅ Backend resources created successfully!

---

## Step 4: Deploy Infrastructure (5 minutes)

Now deploy your actual infrastructure:

1. Still in `Actions` tab
2. Click `Run workflow` again
3. Select **`apply`** from the dropdown
4. Click `Run workflow`

The workflow will:
1. ✅ Validate Terraform code
2. ✅ Create execution plan
3. ✅ Provision EC2 instance
4. ✅ Configure security groups
5. ✅ Install Docker
6. ✅ Run Ansible playbook

After 5-7 minutes, you'll see deployment outputs with your server IP!

---

## Step 5: Access Your Server (30 seconds)

### Get Your Server IP
Look at the workflow output or deployment summary for your server IP.

### Connect via SSH
```bash
ssh -i ~/.ssh/YOUR-KEY-NAME.pem ubuntu@YOUR-SERVER-IP
```

### Verify Everything Works
```bash
# Check Docker
docker --version

# Check Docker Compose
docker compose version

# View installed containers
docker ps
```

---

## 🎉 You're Done!

Your infrastructure is now live and managed by CI/CD!

### What Happens Next?

- **Push to main branch** → Automatically deploys changes
- **Create PR** → Automatically validates and plans changes
- **Merge PR** → Automatically applies changes

### Common Next Steps

1. **Deploy your application**
   - Add your `docker-compose.yml` to the ansible playbook
   - Push to main branch
   - Application deploys automatically!

2. **Configure your domain**
   - Point your domain to the server IP
   - Set up SSL/TLS with Let's Encrypt

3. **Monitor your infrastructure**
   - Check GitHub Actions for deployment history
   - View logs in AWS CloudWatch
   - Monitor costs in AWS Cost Explorer

---

## 🆘 Need Help?

### Issue: "Backend already exists"
**Solution:** Skip step 3. Backend only needs to be created once.

### Issue: "SSH connection timeout"
**Solution:** 
1. Check your security group allows SSH
2. Verify your SSH key is correct
3. Wait a few more minutes for instance to be ready

### Issue: "Bucket name already taken"
**Solution:** Choose a different unique name in Step 2.1

### Issue: Can't connect to server
**Solution:**
```bash
# Check if instance is running
aws ec2 describe-instances --filters "Name=tag:Name,Values=micro_service_server"

# Check security groups allow your IP
# You may need to update the security group in terraform/infrastructure/main.tf
```

---

## 🔄 Regular Operations

### To Update Infrastructure
1. Make changes to Terraform/Ansible files
2. Push to main branch
3. GitHub Actions automatically applies changes

### To Destroy Everything
1. Go to Actions tab
2. Run workflow
3. Select **`destroy`**
4. Confirm in the logs

**Warning:** This deletes everything except the S3 backend!

### To Destroy Backend (Complete Cleanup)
```bash
cd terraform/backend-setup
terraform destroy
```

---

## 📊 Cost Estimate

Monthly AWS costs (approximate):
- EC2 t3.medium: ~$30/month
- S3 storage: ~$0.50/month
- DynamoDB on-demand: ~$0.10/month
- Data transfer: Variable

**Total: ~$31/month**

💡 **Tip:** Use `t3.micro` for testing (free tier eligible)

---

## ✨ Tips for Success

1. **Test in a dev environment first**
2. **Always review the plan** before applying
3. **Keep your .pem file secure** and never commit it
4. **Set up billing alerts** in AWS
5. **Use branch protection** for the main branch
6. **Review Actions logs** after each deployment

---

Ready to deploy? Start with Step 1! 🚀