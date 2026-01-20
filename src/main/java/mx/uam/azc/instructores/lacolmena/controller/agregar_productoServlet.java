package mx.uam.azc.instructores.lacolmena.controller;

import java.io.IOException;
import java.io.Writer;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "agregar_producto", urlPatterns = { "/agregar_producto" })
public class agregar_productoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Constructor vacío
    public agregar_productoServlet() {
        super();
    }

    // Método POST (el que usas cuando envías el formulario)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        // Tipo de respuesta
        response.setContentType("text/html;charset=UTF-8");

        // Salida al navegador
        Writer writer = response.getWriter();
        writer.write("<html><body style='font-family:Arial; text-align:center;'>");
        writer.write("<h2>✅ Servlet funcionando correctamente</h2>");
        writer.write("<p>Hola mundo </p>");
        writer.write("</body></html>");
        writer.flush();
    }

    // (Opcional) Si pruebas con GET en el navegador
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
