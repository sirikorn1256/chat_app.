# The Intelligence HUB (Chat App)

แอปพลิเคชันแชทสนทนา (Chat App) พัฒนาด้วย **Flutter** เน้นการออกแบบ UI/UX สไตล์ลึกลับและเป็นทางการ (Executive Dark Theme) เสมือนแอปพลิเคชันสื่อสารขององค์กรระดับสูง พร้อมเชื่อมต่อระบบฐานข้อมูลและการยืนยันตัวตนแบบ Real-time ผ่าน **Firebase** ครบวงจร

## Features (ฟีเจอร์เด่น)

* **Multi-Provider Authentication**: รองรับการเข้าสู่ระบบที่มีความปลอดภัยผ่าน Firebase Auth ทั้งรูปแบบ Email/Password, Google Sign-In และ GitHub
* **Real-time Global Chat**: ระบบห้องแชทส่วนกลางที่ซิงค์ข้อมูลข้อความแบบ Real-time ทันทีที่มีการโต้ตอบผ่าน Cloud Firestore
* **Profile Image Upload**: รองรับการเลือกรูปภาพจากแกลเลอรี่หรือกล้องถ่ายรูปผ่าน Image Picker และอัปโหลดเก็บรูปโปรไฟล์ไว้อย่างปลอดภัยบน Firebase Storage
* **Executive UI & Stealth Icon**: ออกแบบหน้าจอด้วยโทนสี Tactical Matcha Green ตัดกับสัญลักษณ์ Terminal พร้อมระบบ "ซ่อนรูป" (Front Company) โดยใช้ `flutter_launcher_icons` สร้างไอคอนแอปหน้าจอให้ดูเหมือนแอป FAQ ทั่วไป เพื่อปกปิดตัวตนของแอปแชทที่แท้จริง
* **Dynamic Chat Bubbles**: ระบบแสดงผลกล่องข้อความที่แยกฝั่งผู้ส่ง (ตนเอง) และผู้รับ (ผู้อื่น) อย่างชัดเจน พร้อมแสดงรูปโปรไฟล์และชื่อผู้ใช้งานกำกับทุกข้อความ

## Known Issues & Solutions (ปัญหาที่พบและวิธีการแก้ไข)

1. **ปัญหาคีย์บอร์ดบังช่องพิมพ์ข้อความ (RenderFlex Overflow)**
   * **ปัญหา**: เมื่อกดช่องพิมพ์ข้อความ คีย์บอร์ดเด้งขึ้นมาทับ UI หรือเกิด Error ขอบแดงล้นหน้าจอ
   * **สาเหตุ**: โครงสร้างหน้าจอไม่สามารถปรับขนาดตามพื้นที่ที่ถูกคีย์บอร์ดดันขึ้นมาได้
   * **วิธีการแก้ไข**: ใช้ Widget `Expanded` ครอบส่วนแสดงข้อความ (Chat Messages) และจัดโครงสร้างหน้าจอด้วย `Column` เพื่อให้ช่องพิมพ์ข้อความ (TextField) ถูกคีย์บอร์ดดันขึ้นมาด้านบนเสมอโดยไม่ทับซ้อนกัน

2. **ปัญหาแอปพลิเคชันดูเหมือนค้างระหว่างการสมัครสมาชิกและอัปโหลดรูปภาพ**
   * **ปัญหา**: ผู้ใช้กดยืนยันการสมัครสมาชิกพร้อมรูปโปรไฟล์แล้วหน้าจอไม่มีการตอบสนองทันที
   * **สาเหตุ**: กระบวนการอัปโหลดไฟล์ภาพความละเอียดสูงขึ้น Firebase Storage ต้องใช้เวลาในการส่งข้อมูลผ่านเครือข่าย
   * **วิธีการแก้ไข**: สร้าง State ควบคุมสถานะการโหลด (`_isAuthenticating`) และแสดงผล `CircularProgressIndicator` (วงล้อหมุนโหลด) ระหว่างที่ระบบกำลังประมวลผล เพื่อแจ้งเตือนให้ผู้ใช้ทราบว่าระบบกำลังทำงานอยู่
     
3. **ปัญหาไม่สามารถรันบนระบบปฏิบัติการ Android ได้ (รองรับเฉพาะ iOS Simulator และ Chrome)**
   * **ปัญหา:** เมื่อทำการรันบน Android Emulator มักจะเกิด Error ขัดข้อง
   * **สาเหตุ:** เกิดจากปัญหา Version Mismatch ของ Flutter SDK/Packages บางตัวที่ใช้ในโปรเจกต์นี้ ไม่ตรงกับ Gradle เวอร์ชันปัจจุบันของฝั่ง Android
   * **วิธีการจัดการ:** ตัดสินใจรันทดสอบและพัฒนาบน **iOS Simulator** และ **Chrome** เป็นหลัก เนื่องจากการบังคับอัปเดตเวอร์ชัน SDK แบบ Global ในคอมพิวเตอร์ตอนนี้ **จะส่งผลกระทบทำให้โปรเจกต์เก่าๆ ที่อิงกับเวอร์ชันเดิมพัง (Build failed) ได้** จึงเลี่ยงการอัปเดตเพื่อรักษาเสถียรภาพของโปรเจกต์อื่นๆ ไว้ก่อน

     
## Tech Stack

* **Framework**: Flutter (Dart)
* **Backend/Database**: Firebase Cloud Firestore
* **Authentication**: Firebase Authentication
* **Storage**: Firebase Storage
* **Key Packages**: `image_picker`, `google_sign_in`, `flutter_launcher_icons`



## ผลลัพธ์การทำงานของแอป


## โครงสร้าง

<p align="center">
<img width="389" height="593" alt="โครงสร้าง" src="https://github.com/user-attachments/assets/b2804c57-63b8-4754-997a-01e2e9d3e96c" />
</p>



---

## login 

<p align="center">
<img width="675" height="1437" alt="หน้า login" src="https://github.com/user-attachments/assets/c9a0c635-ee01-477d-8655-5cc57277b88f" />
</p>

---

## login Google 

<p align="center">
<img width="674" height="1440" alt="หน้า login Google" src="https://github.com/user-attachments/assets/4d737aa7-bbe6-4522-ba51-9be12e22b32d" />
</p>

---

## login Github

<p align="center">
<img width="662" height="1437" alt="หน้า login Github" src="https://github.com/user-attachments/assets/50696f40-11e5-4e72-a0e6-8d9350dfda16" />
</p>

---


## Create new account

<p align="center">
<img width="666" height="1434" alt="หน้า Create new account" src="https://github.com/user-attachments/assets/dc358946-3af7-45ef-9ad5-67cec688e99d" />
</p>


---

## Create new account add image

<p align="center">
<img width="671" height="1440" alt="หน้า Create new account add image" src="https://github.com/user-attachments/assets/98c1faee-0e8b-4c87-b5a1-0b979c29cfd2" />
</p>

---

## chat

<p align="center">
<img width="674" height="1436" alt="หน้า chat" src="https://github.com/user-attachments/assets/62d6a887-5703-4ee1-842e-3acd2e8e2106" />
</p>



---

## The results obtained

<p align="center">
<img width="677" height="1433" alt="หน้า ผลลัพธ์ที่ได้" src="https://github.com/user-attachments/assets/4e45c7d8-d668-40ef-9281-4d27f1c902e0" />
</p>



##  New icon app

<p align="center">
<img width="677" height="1438" alt="New icon app" src="https://github.com/user-attachments/assets/4ec3daf5-3f14-4528-9e05-e42d6cb1a1af" />
</p>


---

## Firebase

<p align="center">
<img width="2544" height="1389" alt=" หน้า Firebase" src="https://github.com/user-attachments/assets/4e8e041e-c548-480b-8518-a2a17f9eb9cf" />
</p>

---

## Firebase Firstore

<p align="center">
<img width="2545" height="1395" alt=" หน้า Firebase Firstore" src="https://github.com/user-attachments/assets/c7c85a3a-5a42-4f69-a37c-6ef68129ea67" />
</p>



---

## Firebase User

<p align="center">
<img width="2549" height="1334" alt=" หน้า Firebase User" src="https://github.com/user-attachments/assets/bd31394d-1758-44bb-8fed-1877b2020643" />
</p>

