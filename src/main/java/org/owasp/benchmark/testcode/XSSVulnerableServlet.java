import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/search")
public class XSSVulnerableServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🚨 Vulnerable: Directly includes unescaped input in the response
        String query = request.getParameter("query");

        response.setContentType("text/html");
        response.getWriter().println("<html><body>");
        response.getWriter().println("<h1>Search Results</h1>");
        response.getWriter().println("<p>You searched for: " + query + "</p>");
        response.getWriter().println("</body></html>");
    }
}