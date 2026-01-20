package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import mx.uam.azc.alfabuenamaravillaondadinamitaescuadronlobo.lacolmena.data.editar_cuentaDTO;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.sql.DataSource;

@WebServlet(name = "editar_cuentaDos", urlPatterns = { "/editar_cuentaDos" })
public class editar_cuentaDosServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<editar_cuentaDTO> clientes = getClientes();
            request.setAttribute("clientes", clientes);
        } catch (Exception e) {
            throw new ServletException(e);
        }
        request.getRequestDispatcher("/admin/editar_cuentaDos.jsp")
               .forward(request, response);
    }

    private List<editar_cuentaDTO> getClientes() throws Exception {

        Context ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TestDS");

        try (Connection con = ds.getConnection()) {
            return getClientes(con);
        }
    }

    private List<editar_cuentaDTO> getClientes(Connection con) throws SQLException {

        String sql = "SELECT id_cliente, nombre, apellido_paterno, apellido_materno " +
                     "FROM Cliente";

        try (Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            List<editar_cuentaDTO> lista = new ArrayList<>();

            while (rs.next()) {
                editar_cuentaDTO c = new editar_cuentaDTO();
                c.setId_cliente(rs.getInt("id_cliente"));
                c.setNombre(rs.getString("nombre"));
                c.setApellido_paterno(rs.getString("apellido_paterno"));
                c.setApellido_materno(rs.getString("apellido_materno"));
                lista.add(c);
            }

            return lista;
        }
    }
}
