ในระบบโดยรวม
1.แก้ระบบ Frontend (Nuxt 3 / Vue) Gemini & OpenAI
	แยกว่า dev / production ใช้ไฟล์ไหนก่อนหน้าและพยายามแก้ไข
	ให้ AI ช่วย เปลี่ยน apiBase จาก Railway → Render
2. เชื่อมต่อ Backend ใหม่
	เปลี่ยน endpoint ไป: https://myapp-backend-af5a.onrender.com

3.Build & Deploy
	ให้ AI สอนความต่าง npm run dev,npm run build, npm run generate
	สร้าง static build สำหรับ Hestia
	สอน zip บน Windows (PowerShell)
	ตรวจโครงสร้างไฟล์ก่อน deploy
4. Deploy บน Hestia
	วิธีวางไฟล์ public_html
	บอกไฟล์ที่ไม่ต้อง zip (node_modules)
5. Debug ระดับระบบ
	ให้ AI วิเคราะห์ว่า วิเคราะห์ว่า config มันยิงไป Railway เพราะอะไร
	ให้อธิบายว่า Nuxt embed env ตอน build
	

เมื่อนำขึ้นเซิฟเวอร์ Hestia Gemini & OpenAI
1. ใช้ AI ช่วย Debug และแก้ Error
	ช่วยอธิบาย stack trace
	แนะนำวิธีแก้ middleware loop
2. ใช้ AI ช่วยเขียนและปรับปรุงโค้ด
	แนะนำการใช้ useHead, watch, computed อย่างถูกต้อง

การทำ PBL Copilot
1. ใช้ AI ในการอ่าน souce code เพื่อประหยัดเวลา และทำความเข้าใจระบบ
2. ใช้ AI ในการเพิ่ม Function 
	Incident ,My-Incident และ Admin สำหรับดู Incident โดยสั่งให้สามารถเข้าได้จากลิ้งค์เลย เพื่ออย่างน้อยก็สามารถดูได้ก่อน ตอนนี้ยังติดปัญหาเรื่อง login / database ที่เป็น localhost เดิม 
2. ใช้ AI พยายามแก้ปัญหา และ build
	ใช้AI พยายามแก้ปัญหาที่เกิดขึ้นเช่น ปัญหาเรื่องการ login หรือจะไปหน้าอื่นได้ต้องบังคับ login ก่อนเสมอ 	



AI ช่วยให้เข้าใจและแก้ปัญหาได้เร็วขึ้น แต่การออกแบบโครงสร้าง การตัดสินใจ และการปรับให้เหมาะกับโปรเจกต์ยังต้องใช้ความเข้าใจของผู้พัฒนาเอง โค้ดส่วนมากเป็นแบบ vue การแปลงให้เหมาะกับ hestia ที่เป็น html php จึงต้อง build ใหม่ ,database เดิมของหน้าต่างๆยังชี้ไปตัวทดสอบที่เป็น localhost 3000 ทำให้แก้ไขยากมากในแต่ละขั้นตอน