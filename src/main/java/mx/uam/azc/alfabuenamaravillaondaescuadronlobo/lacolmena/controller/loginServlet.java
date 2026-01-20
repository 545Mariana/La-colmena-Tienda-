package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * @author Usuario
 */
public class loginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private DataSource ds;
    @Override
    public void init() throws ServletException {
        try {
            InitialContext ctx = new InitialContext();
            ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TestDS");
        } catch (Exception e) {
            throw new ServletException(
                "error al iniciar la conexión de la base de datos", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    	//leer action desde mi formulario
        String action = request.getParameter("action");
        if (action == null) action = "login";
        // verifica que haya sesion activa
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            //cierra sesion 
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // para hacer inicio de sesion

        String nombre = request.getParameter("nombre");
        String contrasena = request.getParameter("contrasena");

        if (nombre == null || nombre.trim().isEmpty()
                || contrasena == null || contrasena.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=error");
            return;
        }
        //verificar al cliente existnete
        boolean existe = false;
        int idCliente = 0;

        String sql = "SELECT id_cliente FROM cliente WHERE nombre = ? AND contrasena = ?";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setString(2, contrasena);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    existe = true;
                    idCliente = rs.getInt("id_cliente"); 
                }
            }

        } catch (Exception e) {
            existe = false;
        }
        //guarda datos
        if (existe) {
            HttpSession session = request.getSession(true);
            session.setAttribute("id_cliente", idCliente); 
            session.setAttribute("nombre", nombre);
            //para mostrar el usuario en incio de sesion
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        } 
    }
}
