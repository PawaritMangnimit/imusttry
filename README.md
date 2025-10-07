# Campus Jobs (Spring Boot 3 + Security + JPA)

- Roles: `STAFF`, `STUDENT`
- STAFF = โพสต์งานได้ (`/jobs/new`), ทั้งคู่ดูงานได้ที่ `/`
- Login form: `/login`, Register: `/register`

## Dev (local)
- H2 profile: `mvn spring-boot:run -Dspring-boot.run.profiles=h2`
- หรือใช้ Postgres ของคุณเอง: ตั้งค่า `SPRING_DATASOURCE_URL/USERNAME/PASSWORD`

## Deploy on Render
1. Push โค้ดขึ้น GitHub
2. ไป Render → **New +** → **Blueprint** → เลือก repo นี้
3. Render จะอ่าน `render.yaml` และสร้าง **Postgres DB + Web Service** ให้อัตโนมัติ
4. รอ build เสร็จ → เปิด URL ที่ได้

