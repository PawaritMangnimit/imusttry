#!/usr/bin/env bash
set -euo pipefail

test -f pom.xml || { echo "❌ run at project root (pom.xml)"; exit 1; }

SRC=src/main/java/com/example/campusjobs
RES=src/main/resources
TPL=$RES/templates
mkdir -p "$SRC/controllers" "$RES" "$TPL"

# 1) Security: ให้หน้า public เข้าได้
cat > "$SRC/config/SecurityConfig.java" <<'JAVA'
package com.example.campusjobs.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

  @Bean
  SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      .csrf(csrf -> csrf.disable())
      .authorizeHttpRequests(reg -> reg
        .requestMatchers("/", "/login", "/register", "/ping", "/css/**").permitAll()
        .anyRequest().authenticated()
      )
      .formLogin(form -> form
        .loginPage("/login").permitAll()
        .defaultSuccessUrl("/", true)
      )
      .logout(log -> log.logoutUrl("/logout").logoutSuccessUrl("/").permitAll())
      .httpBasic(b -> b.disable()); // ปิด Basic เพื่อกัน 401 แบบเก่า
    return http.build();
  }
}
JAVA

# 2) Ping endpoint เอาไว้เทสต์ 200 ง่าย ๆ
cat > "$SRC/controllers/PingController.java" <<'JAVA'
package com.example.campusjobs.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PingController {
  @GetMapping("/ping")
  public ResponseEntity<String> ping() {
    return ResponseEntity.ok("OK");
  }
}
JAVA

# 3) HomeController: กัน error DB โดย try/catch แล้วใส่ error ลง model
cat > "$SRC/controllers/HomeController.java" <<'JAVA'
package com.example.campusjobs.controllers;

import com.example.campusjobs.repositories.JobRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
  private final JobRepository jobRepo;
  public HomeController(JobRepository jobRepo) { this.jobRepo = jobRepo; }

  @GetMapping("/")
  public String home(Model model) {
    try {
      model.addAttribute("jobs", jobRepo.findAll());
    } catch (Exception ex) {
      model.addAttribute("jobs", java.util.List.of());
      model.addAttribute("error", "DB unavailable: " + ex.getClass().getSimpleName());
    }
    return "index";
  }
}
JAVA

# 4) Global error handler (ชั่วคราวเพื่อดีบักให้เห็นข้อความบนหน้า)
mkdir -p "$SRC/config"
cat > "$SRC/config/GlobalErrors.java" <<'JAVA'
package com.example.campusjobs.config;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalErrors {
  @ExceptionHandler(Exception.class)
  public ResponseEntity<String> any(Exception e) {
    e.printStackTrace();
    String msg = "ERR: " + e.getClass().getSimpleName() + " - " + (e.getMessage()==null? "" : e.getMessage());
    return ResponseEntity.status(500).body(msg);
  }
}
JAVA

# 5) index.html แบบปลอดภัย (ไม่ใช้ sec:authorize) และแสดง error ถ้ามี
cat > "$TPL/index.html" <<'HTML'
<!doctype html>
<html lang="th" xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Campus Jobs</title>
</head>
<body>
  <h1>รายการงานสำหรับนักศึกษา</h1>
  <p th:if="${error}" style="color:#b00020;" th:text="${error}">มีข้อผิดพลาด</p>
  <div th:if="${#lists.isEmpty(jobs)}">ยังไม่มีงาน</div>
  <ul th:if="${!#lists.isEmpty(jobs)}">
    <li th:each="j : ${jobs}">
      <strong th:text="${j.title}">ชื่องาน</strong>
      <div th:text="${j.description}">รายละเอียด</div>
    </li>
  </ul>
  <p><a href="/login">เข้าสู่ระบบ</a> | <a href="/register">สมัครสมาชิก</a></p>
</body>
</html>
HTML

# 6) เปิด log เพิ่ม (ช่วยอ่านจาก Render logs)
grep -q "^logging.level.org.thymeleaf=" "$RES/application.properties" 2>/dev/null || cat >> "$RES/application.properties" <<'PROP'

# --- debug views (temporary) ---
logging.level.org.thymeleaf=INFO
logging.level.org.springframework.web=INFO
PROP

# 7) build local (optional ถ้ามี Maven)
if command -v mvn >/dev/null 2>&1; then
  mvn -q -DskipTests package || true
fi

git add -A
git commit -m "fix: add /ping, guard DB errors on home, simple index, safer security, debug logs"
git push -u origin main
echo "✅ pushed. Now go to Render → Manual Deploy → Clear build cache & deploy"
