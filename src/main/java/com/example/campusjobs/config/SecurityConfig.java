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
