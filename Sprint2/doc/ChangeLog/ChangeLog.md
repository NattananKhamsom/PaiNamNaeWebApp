รายการบันทึกการเปลี่ยนแปลง (Change Log) - โปรเจกต์ "ไปนำแหน่"

รายการสรุปการพัฒนาและแก้ไขปรับปรุงระบบ ทั้งในส่วนของ Frontend, Backend และการปรับปรุงนโยบายการใช้งาน

🟢  ระบบนโยบายและจริยธรรม (AI & Policy)

เพิ่มไฟล์ ai_declaration.md: (AI Declaration) เพื่อความโปร่งใสในการนำ AI มาช่วยวิเคราะห์พฤติกรรมผู้ใช้และสนับสนุนการตัดสินใจของ Admin

ปรับปรุงระบบ Blacklist Design: แยกหมวดหมู่ความผิดตามบทบาท (D1-D5 สำหรับคนขับ และ P1-P5 สำหรับผู้โดยสาร) เพื่อความชัดเจนในการลงโทษ

🔵 ส่วนของผู้ดูแลระบบ (Admin Dashboard)

ปรับปรุงหน้า User Details (pages/admin/users/[id]/index.vue):

เพิ่ม Safety Center สำหรับจัดการ Blacklist โดยเฉพาะ

เพิ่มระบบการเลือกประเภทความผิด (Category) และการใส่เหตุผล (Reasoning)

เพิ่มระบบ Optimistic UI และการยืนยัน (Confirmation) ก่อนดำเนินการเพื่อป้องกันความผิดพลาด

เชื่อมโยงระบบ Verify เข้ากับสถานะ Blacklist (หากโดนแบนจะยกเลิกการ Verify ทันที)

ปรับปรุงหน้า User Management (pages/admin/users/index.vue):

🔴 ส่วนการแก้ไขปัญหาด้านเทคนิค (Bug Fixes & Deployment)

แก้ไขปัญหา Login (Static Mode): - ปรับปรุง nuxt.config.ts ให้รองรับการเชื่อมต่อ API ข้ามโดเมน (CORS)

ปรับปรุง Backend Middleware: - แก้ไข middlewares/auth.js ให้ตรวจสอบสถานะ isBlacklisted ในทุกๆ Request เพื่อเตะผู้ใช้ที่โดนแบนออกจากระบบทันที

แก้ไขปัญหา Case-sensitivity (User.js vs user.js) สำหรับการรันบน Linux (Render.com)

🟡 ความปลอดภัยและการจัดการข้อมูล (Security & Data)

Database Schema Update: เพิ่มฟิลด์ isBlacklisted และ blacklistReason ในโมเดลฐานข้อมูล User

Authentication: ปรับปรุงระบบการจัดการ Token ให้รองรับทั้ง useCookie และ localStorage เพื่อความยืดหยุ่น

