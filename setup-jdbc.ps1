# Setup JDBC Driver for School Exam System
# This script downloads and configures the MySQL JDBC driver

$ProjectDir = "C:\Users\Admin\StudentActivities\StudentActivities"
$LibDir = Join-Path $ProjectDir "lib"

# Create lib directory if it doesn't exist
if (-not (Test-Path $LibDir)) {
    New-Item -ItemType Directory -Path $LibDir -Force | Out-Null
    Write-Host "✓ Created lib directory: $LibDir"
}

# Download MySQL JDBC Driver from MySQL's official repository
$DownloadUrl = "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.33.jar"
$OutputFile = Join-Path $LibDir "mysql-connector-java-8.0.33.jar"

Write-Host "Downloading MySQL JDBC Driver..."
Write-Host "URL: $DownloadUrl"
Write-Host "Destination: $OutputFile"

try {
    # Use Invoke-WebRequest with error handling
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutputFile -TimeoutSec 120
    
    if (Test-Path $OutputFile) {
        $FileSize = (Get-Item $OutputFile).Length / 1MB
        Write-Host "✓ MySQL JDBC Driver downloaded successfully"
        Write-Host "  File: $(Split-Path $OutputFile -Leaf)"
        Write-Host "  Size: $([Math]::Round($FileSize, 2)) MB"
        Write-Host ""
        Write-Host "✓ Setup complete! You can now run tests with:"
        Write-Host "  javac -cp `"lib/*;src`" src/com/school/exam/test/TestStep4QuestionUpload.java"
        Write-Host "  java -cp `"lib/*;src`" com.school.exam.test.TestStep4QuestionUpload"
    } else {
        Write-Host "✗ Download failed - file not created"
        exit 1
    }
} catch {
    Write-Host "✗ Download failed: $_"
    Write-Host ""
    Write-Host "Alternative setup methods:"
    Write-Host "1. Download manually from: https://dev.mysql.com/downloads/connector/j/"
    Write-Host "2. Place the JAR file in: $LibDir"
    Write-Host "3. Or use Maven: mvn dependency:copy-dependencies"
    exit 1
}
