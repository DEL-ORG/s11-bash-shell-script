#!/bin/bash
#
# simple-resume.sh - A simple resume script using variables.
# Edit the variables below, then run: bash simple-resume.sh

# ----- Personal Info -----
FULL_NAME="Tia Smith"
JOB_TITLE="DevOps Engineer"
LOCATION="Ashburn, VA"
PHONE="(555) 123-4567"
EMAIL="alex.morgan@email.com"
LINKEDIN="linkedin.com/in/alexmorgan"
GITHUB="github.com/alexmorgan"

# ----- Summary -----
SUMMARY="DevOps Engineer with 6+ years of experience in AWS, Azure, Kubernetes, and CI/CD automation. Passionate about building reliable infrastructure and helping teams ship faster."

# ----- Skills -----
SKILLS="AWS, Azure, Kubernetes, Docker, Terraform, Ansible, Jenkins, GitHub Actions, ArgoCD, Bash, Python"

# ----- Job 1 -----
JOB1_TITLE="Senior DevOps Engineer"
JOB1_COMPANY="Contoso Federal Systems"
JOB1_DATES="Jan 2023 - Present"
JOB1_DESC="Designed and deployed EKS clusters, built CI/CD pipelines, and implemented GitOps workflows with ArgoCD."

# ----- Job 2 -----
JOB2_TITLE="DevOps Engineer"
JOB2_COMPANY="Acme Cloud Solutions"
JOB2_DATES="Jun 2020 - Dec 2022"
JOB2_DESC="Provisioned AKS clusters with Terraform and built Jenkins pipelines for microservices."

# ----- Education -----
DEGREE="B.S. Computer Science"
SCHOOL="George Mason University"
GRAD_YEAR="2018"

# ----- Certifications -----
CERT1="AWS Certified Solutions Architect - Associate"
CERT2="Certified Kubernetes Administrator (CKA)"
CERT3="HashiCorp Certified: Terraform Associate"


# =============================================================
# Print the resume
# =============================================================

echo "================================================================"
echo "                         $FULL_NAME"
echo "                         $JOB_TITLE"
echo "================================================================"
echo "$LOCATION  |  $PHONE  |  $EMAIL"
echo "$LINKEDIN  |  $GITHUB"
echo "================================================================"
echo ""
echo "SUMMARY"
echo "----------------------------------------------------------------"
echo "$SUMMARY"
echo ""
echo "SKILLS"
echo "----------------------------------------------------------------"
echo "$SKILLS"
echo ""
echo "EXPERIENCE"
echo "----------------------------------------------------------------"
echo "$JOB1_TITLE"
echo "$JOB1_COMPANY  |  $JOB1_DATES"
echo "$JOB1_DESC"
echo ""
echo "$JOB2_TITLE"
echo "$JOB2_COMPANY  |  $JOB2_DATES"
echo "$JOB2_DESC"
echo ""
echo "EDUCATION"
echo "----------------------------------------------------------------"
echo "$DEGREE"
echo "$SCHOOL, $GRAD_YEAR"
echo ""
echo "CERTIFICATIONS"
echo "----------------------------------------------------------------"
echo "* $CERT1"
echo "* $CERT2"
echo "* $CERT3"