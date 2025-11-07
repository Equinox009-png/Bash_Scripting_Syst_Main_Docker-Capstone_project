System Maintenance Suite (Docker + Bash)

A lightweight, Dockerized System Maintenance Suite built entirely with Bash scripting.
It automates routine system tasks such as backups, updates, cleanup, and log monitoring —
all accessible via a simple interactive menu.

🚀 Features

🗂 Automated Backups — Create timestamped .tar.gz backups of any directory
and keep only the last N backups automatically.

⚙️ System Update & Cleanup — Perform apt update, upgrade, and cleanup
operations in a controlled container environment.

🧾 Log Monitoring — Scan any log file for critical keywords like
error, fail, unauthorized, critical, and panic,
with results saved to structured logs.

🧭 Interactive Menu — Easily run all modules manually via a
text-based interactive interface.

🐳 Dockerized Setup — Self-contained environment with all dependencies
(Bash, cron, coreutils, etc.) built into a minimal Ubuntu image.

📁 Project Structure
sys_maint_docker/
├── Dockerfile                 # Docker image definition
├── entrypoint.sh              # Container entrypoint
├── scripts/
│   ├── backup.sh              # Creates backups and rotates old ones
│   ├── update_cleanup.sh      # Updates & cleans packages
│   ├── log_monitor.sh         # Scans log files for errors/warnings
│   └── suite_menu.sh          # Interactive menu interface
└── data/
    ├── source/                # Input files (source directories/logs)
    ├── backups/               # Output backups (.tar.gz)
    └── logs/                  # Generated logs (per-module + alerts)

⚙️ Prerequisites

Docker Desktop installed and running

Git Bash or WSL (Ubuntu) terminal

Basic familiarity with command line usage

🧩 Setup Instructions
1️⃣ Clone the repository
git clone https://github.com/Equinox009-png/sys_maint_docker.git
cd sys_maint_docker

2️⃣ Build the Docker image
docker build -t sys_maint_suite:latest .

3️⃣ Prepare data folders
mkdir -p data/logs data/backups data/source


(Optional: create a test log file)

echo "2025-11-07 ERROR: Disk space low" > data/source/sample.log

💻 Usage
▶️ Run Interactive Menu (recommended)

In Git Bash:

MSYS_NO_PATHCONV=1 docker run --rm -it \
  -v "C:/Users/KANHA/Documents/sys_maint_docker/data:/data" \
  -v "C:/Users/KANHA/Documents/sys_maint_docker/scripts:/workspace/scripts" \
  -v "C:/Users/KANHA:/host/Users/KANHA:ro" \
  sys_maint_suite:latest /workspace/scripts/suite_menu.sh


Menu Options:

===========================================
   🔧 System Maintenance Suite - MENU
===========================================
1) Run Backup Now
2) Run Update & Cleanup
3) Run Log Monitor
4) Show Scripts Directory
5) Run Full Maintenance Suite
6) Exit
===========================================

🗂 Example Paths
Windows Path	Docker Path Inside Container
C:\Users\KANHA\Documents\sys_maint_docker\data	/data
C:\Users\KANHA\Documents\sys_maint_docker\data\source\sample.log	/data/source/sample.log
C:\Users\KANHA\Desktop\hero	/host/Users/KANHA/Desktop/hero
🧾 Log Output
Module	Log File
Backup	/data/logs/backup.log
Update & Cleanup	/data/logs/update_cleanup.log
Log Monitor	/data/logs/log_monitor.log
Alerts Summary	/data/logs/alerts.log
Full Run	/data/logs/full_run_<timestamp>.log

All logs are automatically created inside data/logs.

🧮 Example Backup Command

To manually run a backup (outside the menu):

MSYS_NO_PATHCONV=1 docker run --rm -it \
  -v "C:/Users/KANHA/Documents/sys_maint_docker/data:/data" \
  -v "C:/Users/KANHA:/host/Users/KANHA:ro" \
  sys_maint_suite:latest /workspace/scripts/backup.sh \
  /host/Users/KANHA/Documents/projects /data/backups 3 /data/logs/backup_test.log

🧹 Cleaning Up

To remove all containers:

docker ps -a
docker stop <container_id>
docker rm <container_id>


To rebuild the image after making script changes:

docker build -t sys_maint_suite:latest .

📊 Sample Outputs

Backup Completed

[2025-11-07 22:05:47] Archive created: /data/backups/projects_backup_2025-11-07_220547.tar.gz
[2025-11-07 22:05:47] Backup finished successfully


Log Monitor Results

[2025-11-07 17:52:43] Found matches for 'error':
4:2025-11-07 ERROR: Disk space low on drive C:
👩‍💻 Author

Developed by: Jyoti Prakash Swain 
Branch: Electronics and Communication Engineering
Year: 4th Year
Feel free to modify it and improve its functionality!

👩‍💻 Author

Developed by: Jyoti Prakash Swain (Equinox)
Branch: Electronics and Communication Engineering
Year: 3rd Year
