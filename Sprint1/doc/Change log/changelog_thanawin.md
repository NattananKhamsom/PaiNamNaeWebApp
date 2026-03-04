Changelog_thanawin
-Database (schema.prisma)

เพิ่มฟิลด์ใน User

isDeleted: Boolean @default(false)

deletedAt: DateTime?

เพิ่ม @@index([isDeleted, deletedAt])

รองรับการลบบัญชีแบบ Soft Delete และเตรียมรองรับการลบถาวรในอนาคต

-Service (user.service.js)

เพิ่มฟังก์ชัน requestAccountDeletion(id)

ตั้งค่า isDeleted = true

ตั้งค่า isActive = false

บันทึก deletedAt

-Controller (user.controller.js)

เพิ่ม requestDeleteMyAccount

รองรับการลบบัญชีของผู้ใช้ที่ login อยู่

-Routes (user.routes.js)

เพิ่ม DELETE /api/users/me

ใช้ protect middleware เพื่อให้ลบได้เฉพาะบัญชีตนเอง

-Frontend (index.vue)

เพิ่ม “Danger Zone” ในหน้าโปรไฟล์

เพิ่ม handleDeleteAccount()

แสดง confirm dialog

เรียก API ลบบัญชี

Logout อัตโนมัติ

ลบ token ใน localStorage / sessionStorage
