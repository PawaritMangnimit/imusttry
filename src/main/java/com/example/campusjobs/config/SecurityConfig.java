package com.example.campusjobs.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import com.example.campusjobs.services.DbUserDetailsService;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

  @Bean BCryptPasswordEncoder passwordEncoder(){ return new BCryptPasswordEncoder(); }

  @Bean
  DaoAuthenticationProvider authProvider(DbUserDetailsService uds, BCryptPasswordEncoder enc){
    DaoAuthenticationProvider p = new DaoAuthenticationProvider();
    p.setUserDetailsService(uds); p.setPasswordEncoder(enc); return p;
  }

  @Bean
  SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      .csrf(AbstractHttpConfigurer::disable)
      .httpBasic(AbstractHttpConfigurer::disable)
      .authorizeHttpRequests(reg -> reg
        .requestMatchers("/", "/login", "/register", "/error",
                         "/css/**", "/js/**", "/images/**", "/webjars/**").permitAll()
        .requestMatchers("/jobs/new", "/jobs").hasRole("STAFF")
        .anyRequest().authenticated()
      )
      .formLogin(form -> form
        .loginPage("/login").permitAll()
        .defaultSuccessUrl("/", true)
      )
      .logout(log -> log.logoutUrl("/logout").logoutSuccessUrl("/").permitAll());
    return http.build();
  }
}
