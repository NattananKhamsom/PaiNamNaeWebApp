ผมอ่านไฟล์แล้ว และแปลพร้อม **เรียบเรียงใหม่ให้ดูเป็นเอกสารที่อ่านง่ายขึ้น** โดยใช้ **ตาราง + โครงสร้างชัดเจนกว่าเดิม** ดังนี้

---

# ระบบ Ticket สำหรับ Blacklist

## ภาพรวมระบบ

ระบบได้เปลี่ยนจากปุ่ม **“Blacklist ถาวร” แบบเดิม** มาเป็นระบบ **Ticket + Card** แทน

ผู้ดูแลระบบ จะออก **ใบเหลือง หรือ ใบแดง** ผ่านหน้า Ticket โดยระบบจะตรวจสอบและทำการ Blacklist อัตโนมัติตามกฎที่กำหนด

### กฎของระบบ

| จำนวนการ์ด     | ผลลัพธ์             
| -------------- | -------------------
| 1 Yellow Card  | แจ้งเตือนผู้ใช้     
| 2 Yellow Cards | Blacklist อัตโนมัติ 
| 1 Red Card     | Blacklist ทันที     

---

# การเปลี่ยนแปลงในระบบ

## Backend (8 ไฟล์)

| ไฟล์                          | การเปลี่ยนแปลง | รายละเอียด                                                                    
| ----------------------------- | -------------- | ----------------------------------------------------------------------------- 
| schema.prisma                 | แก้ไข          | เพิ่ม Model `BlacklistedTicket` และ Enum `CardType` พร้อม relation กับ `User` 
| blacklistTicket.service.js    | สร้างใหม่      | จัดการ logic CRUD และตรวจสอบการ Blacklist อัตโนมัติ                           
| blacklistTicket.controller.js | สร้างใหม่      | API สำหรับสร้าง Ticket และดูรายการ Ticket ของผู้ใช้                           
| blacklistTicket.validation.js | สร้างใหม่      | ตรวจสอบข้อมูลด้วย Zod เช่น cardType, category, reason, userId                 
| blacklistTicket.routes.js     | สร้างใหม่      | Route สำหรับ Admin ที่ `/api/blacklist-tickets`                               
| index.js                      | แก้ไข          | เพิ่มการ register route ของ blacklist ticket                                  

### Prisma Migration

| รายการ         | สถานะ                    |
| -------------- | ------------------------ |
| Migration name | `add_blacklisted_ticket` |
                           

---

## Frontend (2 ไฟล์)

| ไฟล์       | การเปลี่ยนแปลง | รายละเอียด                                                                                            
| ---------- | -------------- | ----------------------------------------------------------------------------------------------------- 
| index.vue  | แก้ไข          | ลบฟอร์ม blacklist แบบเดิม เปลี่ยนเป็นข้อมูลกฎการ์ด และปุ่มไปหน้า Ticket                               
| ticket.vue | สร้างใหม่      | หน้า Ticket เต็มรูปแบบ มีเลือกการ์ด, ฟอร์มกรอกเหตุผล, ประวัติ ticket และแจ้งเตือน blacklist อัตโนมัติ 

---

# API ที่ใช้

| Method | Endpoint                            | รายละเอียด                       
| ------ | ----------------------------------- | -------------------------------- 
| POST   | `/api/blacklist-tickets`            | สร้าง Ticket (Yellow / Red Card) 
| GET    | `/api/blacklist-tickets?userId=xxx` | ดู Ticket ทั้งหมดของผู้ใช้       

---

# การตรวจสอบระบบ

| รายการ             | สถานะ                                                                     
| ------------------ | -------------------------------------------------------------------------
| Prisma Migration   | สำเร็จ                                                                    
| Prisma Client      | Generate เรียบร้อย                                                        
| Backend Structure  | ใช้ pattern เดิมของระบบ (asyncHandler, Zod, protect/requireAdmin)         
| Frontend Structure | ใช้โครงสร้างเดิม (AdminHeader, AdminSidebar, useToast, dayjs buddhistEra) 

