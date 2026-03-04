param(
  [Parameter(Mandatory=$true)]
  [string]$Ec2Host,

  [string]$Ec2User = "ec2-user",
  [string]$PemPath = "C:\Users\user\Desktop\daneo_학습앱\daneo-app\maru-ec2-seoul-main.pem",
  [string]$RdsHost = "efl-db.czmumoegmwa5.ap-northeast-2.rds.amazonaws.com",
  [int]$LocalPort = 3307,
  [int]$RdsPort = 3306
)

if (-not (Test-Path $PemPath)) {
  Write-Error "PEM not found: $PemPath"
  exit 1
}

$ssh = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $ssh) {
  Write-Error "ssh command not found. Install OpenSSH client first."
  exit 1
}

Write-Host "[1/3] Applying secure permission to PEM..."
icacls $PemPath /inheritance:r | Out-Null
icacls $PemPath /grant:r "$($env:USERNAME):(R)" | Out-Null

Write-Host "[2/3] Starting SSH tunnel..."
Write-Host "      Local 127.0.0.1:$LocalPort -> RDS $RdsHost:$RdsPort"
Write-Host "      Keep this terminal open while using the app."

$forward = "${LocalPort}:${RdsHost}:${RdsPort}"
$target = "${Ec2User}@${Ec2Host}"

ssh -i $PemPath -o ExitOnForwardFailure=yes -N -L $forward $target
