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

@WebServlet(name = "HelloServlet", urlPatterns = {"/hello", "/api/hello"})
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> jsonResponse = new HashMap<>();
        jsonResponse.put("status", "success");
        jsonResponse.put("message", "Hello from DevOps Tomcat Application!");
        jsonResponse.put("version", "1.0.0");
        jsonResponse.put("timestamp", System.currentTimeMillis());
        jsonResponse.put("server", "Apache Tomcat");
        
        String name = request.getParameter("name");
        if (name != null && !name.isEmpty()) {
            jsonResponse.put("greeting", "Hello, " + name + "!");
        }
        
        Gson gson = new Gson();
        String json = gson.toJson(jsonResponse);
        
        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
