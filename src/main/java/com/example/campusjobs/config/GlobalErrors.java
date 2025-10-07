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
