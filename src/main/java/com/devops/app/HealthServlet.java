package com.devops.app;

import com.google.gson.Gson;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "HealthServlet", urlPatterns = {"/health"})
public class HealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> healthStatus = new HashMap<>();
        healthStatus.put("status", "UP");
        healthStatus.put("application", "devops-app");
        healthStatus.put("version", "1.0.0");
        
        Map<String, String> details = new HashMap<>();
        details.put("java_version", System.getProperty("java.version"));
        details.put("os", System.getProperty("os.name"));
        details.put("uptime", String.valueOf(System.currentTimeMillis()));
        
        healthStatus.put("details", details);
        
        Gson gson = new Gson();
        String json = gson.toJson(healthStatus);
        
        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }
}
