package com.devops.app;

import org.junit.Test;
import static org.junit.Assert.*;

public class HelloServletTest {

    @Test
    public void testServletExists() {
        HelloServlet servlet = new HelloServlet();
        assertNotNull("Servlet should not be null", servlet);
    }
    
    @Test
    public void testApplicationLogic() {
        // Simple test to ensure build succeeds
        String message = "Hello from DevOps Tomcat Application!";
        assertNotNull("Message should not be null", message);
        assertTrue("Message should contain 'DevOps'", message.contains("DevOps"));
    }
    
    @Test
    public void testVersionNumber() {
        String version = "1.0.0";
        assertEquals("Version should be 1.0.0", "1.0.0", version);
    }
}
