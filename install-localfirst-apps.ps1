# install-localfirst-apps.ps1
# 安装 localfirst-apps 到指定目录，并提示用户通过 control-panel.exe 管理后续内容

param(
    # 可选：静默安装时直接指定目标目录，例如：
    # .\install-localfirst-apps.ps1 E:\
    [Parameter(Position = 0)]
    [string]$InstallDir
)

# ============ 编码保护头部 ============
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    chcp 65001 > $null 2>&1
} catch { }
# ======================================

$repoName   = "localfirst-apps"
$zipUrl     = "https://gh-proxy.org/https://github.com/ruoyousi/localfirst-apps/archive/refs/heads/master.zip"
$controlApp = "control-panel.exe"

function Show-Banner {
    Write-Host ""
    Write-Host "============================================"
    Write-Host "  $repoName 安装脚本"
    Write-Host "============================================"
    Write-Host ""
}

function Show-Notice {
    Write-Host "注意：$repoName 可能会按需下载程序包或模型文件。"
    Write-Host "这些文件可能占用较大磁盘空间，建议安装到剩余空间充足的磁盘分区。"
    Write-Host ""
}

function Test-EnoughSpace {
    param([string]$path)

    try {
        $drive = [System.IO.Path]::GetPathRoot($path)
        if (-not $drive) { return $true }

        $driveInfo = New-Object System.IO.DriveInfo($drive)
        $freeGB    = [math]::Round($driveInfo.AvailableFreeSpace / 1GB, 2)

        Write-Host "目标磁盘 $drive 剩余空间：$freeGB GB"
        return $true
    }
    catch {
        Write-Host "无法检测目标磁盘剩余空间，请自行确认磁盘空间充足。"
        return $true
    }
}

function Get-InstallDirectory {
    if ($InstallDir) {
        $resolved = Resolve-Path -LiteralPath $InstallDir -ErrorAction SilentlyContinue
        if ($resolved) {
            $fullPath = $resolved.Path
        }
        else {
            $fullPath = $InstallDir
        }

        $fullPath = $fullPath.TrimEnd('\', '/')
        return Join-Path $fullPath $repoName
    }

    $defaultDir = Join-Path $env:USERPROFILE $repoName

    Write-Host "默认安装目录：$defaultDir"
    Write-Host ""
    $custom = Read-Host "是否自定义安装目录？直接回车使用默认目录，否则请输入完整路径"

    if ($custom -and $custom.Trim()) {
        $custom = $custom.Trim().TrimEnd('\', '/')
        return Join-Path $custom $repoName
    }

    return $defaultDir
}

function Confirm-Install {
    param([string]$target)

    Write-Host ""
    Write-Host "即将安装到：$target"
    $confirm = Read-Host "确认继续安装？(Y/N)"

    if ($confirm -notmatch '^[Yy]') {
        Write-Host "已取消安装。"
        exit 0
    }
}

function Download-Zip {
    param([string]$dest)

    Write-Host ""
    Write-Host "正在下载 $repoName ..."
    Write-Host "来源：$zipUrl"
    Write-Host ""

    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $dest -UseBasicParsing
    }
    catch {
        Write-Host "下载失败：$_" -ForegroundColor Red
        Write-Host "请检查网络连接，或稍后重试。" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path -LiteralPath $dest)) {
        Write-Host "下载完成但未找到文件：$dest" -ForegroundColor Red
        exit 1
    }

    $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 2)
    Write-Host "下载完成，文件大小约 $sizeMB MB。"
}

function Extract-Zip {
    param(
        [string]$zipPath,
        [string]$targetDir
    )

    Write-Host ""
    Write-Host "正在解压到：$targetDir"

    $tempDir = Join-Path $env:TEMP "localfirst-apps-install-$([System.Guid]::NewGuid())"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        Expand-Archive -LiteralPath $zipPath -DestinationPath $tempDir -Force

        $extractedRoot = Get-ChildItem -Path $tempDir -Directory |
            Where-Object { $_.Name -like "$repoName-*" } |
            Select-Object -First 1

        if (-not $extractedRoot) {
            $extractedRoot = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
        }

        if (-not $extractedRoot) {
            Write-Host "解压后未找到预期目录，安装失败。" -ForegroundColor Red
            exit 1
        }

        if (Test-Path -LiteralPath $targetDir) {
            Write-Host "目标目录已存在，将覆盖安装：$targetDir"
            Remove-Item -LiteralPath $targetDir -Recurse -Force
        }

        $parentDir = Split-Path -Parent $targetDir
        if (-not (Test-Path -LiteralPath $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        Move-Item -LiteralPath $extractedRoot.FullName -Destination $targetDir -Force

        Write-Host "解压完成。"
    }
    finally {
        if (Test-Path -LiteralPath $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Show-Done {
    param([string]$targetDir)

    $exePath = Join-Path $targetDir $controlApp

    Write-Host ""
    Write-Host "============================================"
    Write-Host "  $repoName 安装完成"
    Write-Host "============================================"
    Write-Host ""
    Write-Host "安装目录：$targetDir"
    Write-Host ""

    if (Test-Path -LiteralPath $exePath) {
        Write-Host "请双击运行以下程序启动控制面板："
        Write-Host ""
        Write-Host "$exePath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "在控制面板中可以下载需要的软件包或模型文件，并启停应用或服务。"
    }
    else {
        Write-Host "未找到 $controlApp，请检查安装目录内容。" -ForegroundColor Yellow
    }

    Write-Host ""
}

# ---------- 主流程 ----------

Show-Banner
Show-Notice

$targetDir = Get-InstallDirectory

if (-not (Test-EnoughSpace $targetDir)) {
    Write-Host "目标磁盘空间不足，安装已取消。" -ForegroundColor Red
    exit 1
}

if (-not $InstallDir) {
    Confirm-Install $targetDir
}

$zipPath = Join-Path $env:TEMP "localfirst-apps-master.zip"

try {
    Download-Zip $zipPath
    Extract-Zip $zipPath $targetDir
}
finally {
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
    }
}

Show-Done $targetDir
