# 🚀 Drift Detection Quick Reference

## 📧 Required Secrets (Choose ONE Email Method)

### Option A: SMTP (Gmail Example)
```
SMTP_SERVER = smtp.gmail.com
SMTP_PORT = 587
SMTP_USERNAME = your-email@gmail.com
SMTP_PASSWORD = your-16-char-app-password
ALERT_EMAIL = team@company.com
FROM_EMAIL = your-email@gmail.com
```

### Option B: SendGrid
```
SENDGRID_API_KEY = SG.xxxxxxxxxxxxx
ALERT_EMAIL = team@company.com
FROM_EMAIL = verified-sender@company.com
```

### Optional: Slack
```
SLACK_WEBHOOK_URL = https://hooks.slack.com/services/xxx/yyy/zzz
```

---

## 🛡️ Setup Environment Protection (REQUIRED)

1. `Settings` → `Environments` → `New environment`
2. Name: `production-approval`
3. Check ✅ "Required reviewers"
4. Add team members
5. Save

---

## 🔄 Workflow Triggers

| Trigger | When | What Happens |
|---------|------|--------------|
| **Push to main** | Code changes | Auto-runs, pauses if drift |
| **Pull Request** | PR opened | Shows plan, no apply |
| **Schedule** | Daily 9 AM UTC | Checks for drift |
| **Manual** | Any time | Run on-demand |

---

## 📊 Drift Detection Flow

```
1. Code pushed → Validate
2. Run terraform plan
3. Drift found? 
   ├─ YES → Email alert → Wait for approval → Apply
   └─ NO → Apply automatically ✅
```

---

## ✅ What to Do When You Get a Drift Alert

1. **Read the email** - Check what changed
2. **Open workflow link** - View full plan
3. **Go to Actions tab** - See workflow status
4. **Click "Review deployments"** - Approve or reject
5. **Approve** - Changes applied automatically
6. **Get success email** - Confirmation sent

---

## 🧪 Quick Test

```bash
# 1. Trigger manually
GitHub → Actions → Run workflow → Select "drift-check"

# 2. Create drift manually
AWS Console → EC2 → Select your instance → Add tag: "test = drift"

# 3. Wait for scheduled run or push code
# You should receive email alert

# 4. Approve in GitHub
Actions → Review deployments → Approve

# 5. Drift is fixed!
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| No email received | Check spam, verify secrets, check logs |
| Can't approve | Create `production-approval` environment |
| Drift not detected | Verify state backend, make visible change |
| SMTP fails | Test credentials, check firewall, use app password |

---

## 📞 Gmail App Password Setup (30 seconds)

1. Enable 2FA: https://myaccount.google.com/security
2. App passwords: https://myaccount.google.com/apppasswords
3. Select "Mail" and "Other (Custom name)"
4. Copy 16-character password
5. Use as `SMTP_PASSWORD` secret

---

## 🎯 Key Behaviors

✅ **No drift** → Deploys automatically  
📧 **Drift detected** → Email + pause + approval  
🔄 **Daily check** → Automated at 9 AM UTC  
🎫 **GitHub issue** → Auto-created on drift  
📊 **PR comments** → Shows plan on PRs  

---

## 📋 Checklist

- [ ] Add SMTP or SendGrid secrets
- [ ] Create `production-approval` environment
- [ ] Add yourself as required reviewer
- [ ] Test with manual trigger
- [ ] Simulate drift and approve
- [ ] ✅ You're protected!

---

**Need detailed setup?** See `DRIFT_DETECTION_SETUP.md`