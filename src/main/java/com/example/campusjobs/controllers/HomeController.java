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
