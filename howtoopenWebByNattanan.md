CMD1

cd C:\Users\User\PaiNamNaeWebApp\backend
npm install
npx prisma generate
npm run dev


CMD2

cd C:\Users\User\PaiNamNaeWebApp\frontend
npm install
npm run dev


http://localhost:3001/ สำหรับหน้า frontend



ให้ AI ช่วยจัดการการเปิดหน้าเว็บปัญหาหลักๆตอนนี้จะอยู่ที่ API บางอันต้องเสียเงินบางอันเชื่อไม่ติด อาจจะเพราะขาดประสบการณ์จากผู้พัฒนาเอง

วันนี้ 10/2/69 จะทำ 
6 11 13

As an admin, I want to keep the users updated on their reported incidents.


As a driver, I want to report incidents to the admin and get the update on the filed case.

As a passenger, I want to report the driver behavior to the admin and get the update on the filed case.

For Users:
- Report Incident: `http://localhost:3001/report-incident`
- My Incidents: `http://localhost:3001/my-incidents`

For Admins:
- Incident Management: `http://localhost:3001/admin/incidents`
- API Docs: `http://localhost:3000/documentation` (see Incidents tag)


เพราะว่า แต่ละอันจะสอดคล้องกันจึงเหมาะสมต่อการลองทำด้วยกัน

ผมใช้ AI Copilot โดยผมบอกว่าควรจะเป็นแบบไหนหรือยังไงเช่นการ 