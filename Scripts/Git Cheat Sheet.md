Git Cheat Sheet
===============
# …or create a new repository on the command line
echo "# QuartoManuscriptPMPH" >> README.md
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/urcclaw/QuartoManuscriptPMPH.git
git push -u origin main

# …or push an existing repository from the command line
git remote add origin https://github.com/urcclaw/QuartoManuscriptPMPH.git
git branch -M main
git push -u origin main


การตั้งค่าเริ่มต้น
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"

สร้าง ssh-keygen
ssh-keygen -t ed25519 -C "your_email@example.com"

แสดง public key บน Linux
cat ~/.ssh/id_ed25519.pub

แสดง public key บน Windows
type C:\Users\YourUsername\.ssh\id_ed25519.pub

สร้างไฟล์เปล่าบน Windows
type nul > hello.py

เปิด Nodepad
notepad hello.py

ลบ Folder และไฟล์บน Windows
rmdir /s /q gitpro

สร้างและ Clone Repository
git init                   # สร้าง repository ใหม่
git clone [url]            # โคลน repository จาก URL

การทำงานกับไฟล์
git add [file]             # เพิ่มไฟล์เข้า staging area
git add .                  # เพิ่มทุกไฟล์ที่มีการเปลี่ยนแปลง

การ Commit
git commit -m "[message]"  # สร้าง commit พร้อมข้อความ
git commit --amend         # แก้ไข commit ล่าสุด
git commit --amend --no-edit # เพิ่มการแก้ไขเข้า Commit ล่าสุด

การตรวจสอบสถานะ
git status                 # แสดงสถานะของไฟล์
git diff                   # แสดงการเปลี่ยนแปลงที่ยังไม่ได้ stage
git log                    # แสดงประวัติ commit
git log --oneline --stat   # แสดงประวัติแบบ Stat

การทำงานกับ Branch
git branch                 # แสดงรายการ branch

การทำงานกับ Remote
git remote add [name] [url] # เพิ่ม remote repository
git remote -v               # แสดงรายการ remote
git push [remote] [branch]  # ส่งการเปลี่ยนแปลงไปยัง remote
git push -f [remote] [branch]
# แทนที่สิ่งที่อยู่บน remote (ซึ่งควรทำด้วยความระมัดระวังเพราะอาจสูญเสียประวัติการเปลี่ยนแปลงบน remote ได้)

git remote remove origin    # ลบ remote origin

การยกเลิกการเปลี่ยนแปลง
git reset [file]           # ยกเลิกการ stage ไฟล์
git reset --soft [commitid]
# ลบ Commit ทุก Commit หลัง Commit ID แล้วนำไฟล์ที่เคยอยู่ใน Commit เหล่านั้นกลับมายัง Staging Area

git reset --mixed [commitid] หรือ git reset [commitid]
# ลบ Commit ทุก Commit หลัง Commit ID แล้วนำไฟล์ที่เคยอยู่ใน Commit เหล่านั้นกลับมายัง Working Directory

git reset --hard [commitid]
# ลบ Commit ทุก Commit หลัง Commit ID และทำลายไฟล์ที่เคยอยู่ใน Commit เหล่านั้น

การกู้คืนไฟล์
git checkout sub.py        # กู้คืนไฟล์ sub.py จาก commit ล่าสุด

การทำงานกับ Branch
git branch                     # แสดงรายการ branch ท้องถิ่น
git branch -r                  # แสดงรายการ remote branch
git branch -a                  # แสดงรายการ branch ทั้งหมด (ท้องถิ่นและ remote)
git branch [branch-name]       # สร้าง branch ใหม่
git checkout -b [branch-name]  # สร้างและสลับไปยัง branch ใหม่
git checkout [branch-name]     # สลับไปยัง branch ที่มีอยู่
git merge [branch-name]        # รวม branch ปัจจุบันกับ branch ที่ระบุ
git branch -d [branch-name]    # ลบ branch ท้องถิ่น
git push origin --delete [branch-name] # ลบ remote branch
git branch -m [old-name] [new-name] # เปลี่ยนชื่อ branch
git push -u origin [branch-name] # Push branch ไปยัง remote และตั้งค่า upstream