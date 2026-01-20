package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import mx.uam.azc.alfabuenamaravillaondadinamitaescuadronlobo.lacolmena.data.editar_cuentaDTO;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "editar_cuenta", urlPatterns = { "/editar_cuenta" })
public class editar_cuentaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DataSource ds;

    @Override
    public void init() throws ServletException {
        try {
            Context ctx = new InitialContext();
            ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TestDS");
        } catch (Exception e) {
            throw new ServletException("Error obteniendo DataSource", e);
        }
    }

    // =========================
    // GET -> CONSULTA (SELECT)
    // =========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_cliente") == null) {
            // no hay sesión -> manda a login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idCliente = (Integer) session.getAttribute("id_cliente");

        String sql = "SELECT * FROM Cliente WHERE id_cliente = ?";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idCliente);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    request.setAttribute("id_cliente", rs.getInt("id_cliente"));
                    request.setAttribute("nombre", rs.getString("nombre"));
                    request.setAttribute("apellido_paterno", rs.getString("apellido_paterno"));
                    request.setAttribute("apellido_materno", rs.getString("apellido_materno"));
                    request.setAttribute("contrasena", rs.getString("contrasena"));
                    request.setAttribute("domicilio", rs.getString("domicilio"));
                    request.setAttribute("codigo_postal", rs.getString("codigo_postal"));
                    request.setAttribute("num_telefonico", rs.getString("num_telefonico"));
                    request.setAttribute("tarjeta_credito", rs.getString("tarjeta_credito"));
                    request.setAttribute("fecha_expiracion", rs.getString("fecha_expiracion"));
                } else {
                    response.sendRedirect(request.getContextPath() + "/editar_cuenta.jsp?msg=error");
                    return;
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/editar_cuenta.jsp").forward(request, response);
    }

    // ==========================================
    // POST -> UPDATE (SOLO AL CLIENTE EN SESIÓN)
    // ==========================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    	request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_cliente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            updateCliente(request);
        } catch (Exception e) {
            throw new ServletException(e);
        }

        // ya no mandamos id_cliente por URL porque se toma de sesión
        response.sendRedirect(request.getContextPath() + "/editar_cuenta.jsp?msg=ok");
    }

    // =========================================================
    // updateCliente(request):
    // 1) armar DTO
    // 2) obtener conexión
    // 3) delegar update real
    // =========================================================
    private void updateCliente(HttpServletRequest request) throws Exception {

        editar_cuentaDTO cliente = getClienteDesdeSesion(request);
        String campo = request.getParameter("campo");

        try (Connection con = ds.getConnection()) {
            updateCliente(con, cliente, campo);
        }
    }

    // =========================================================
    // getClienteDesdeSesion(request):
    // construye el DTO usando id_cliente DE SESIÓN + campo/valor
    // =========================================================
    private editar_cuentaDTO getClienteDesdeSesion(HttpServletRequest request) {

        HttpSession session = request.getSession(false);

        editar_cuentaDTO c = new editar_cuentaDTO();

        int idCliente = (Integer) session.getAttribute("id_cliente");
        String campo = request.getParameter("campo");
        String valor = request.getParameter("valor");

        c.setId_cliente(idCliente);

        // Solo llenamos el campo que se va a modificar
        if ("nombre".equals(campo)) c.setNombre(valor);
        if ("apellido_paterno".equals(campo)) c.setApellido_paterno(valor);
        if ("apellido_materno".equals(campo)) c.setApellido_materno(valor);
        if ("contrasena".equals(campo)) c.setContrasena(valor);
        if ("domicilio".equals(campo)) c.setDomicilio(valor);
        if ("codigo_postal".equals(campo)) c.setCodigo_postal(valor);
        if ("num_telefonico".equals(campo)) c.setNum_telefonico(valor);
        if ("tarjeta_credito".equals(campo)) c.setTarjeta_credito(valor);
        if ("fecha_expiracion".equals(campo)) c.setFecha_expiracion(valor);

        return c;
    }

    // =========================================================
    // updateCliente(con, dto, campo):
    // PreparedStatement real
    // =========================================================
    private void updateCliente(Connection con, editar_cuentaDTO cliente, String campo)
            throws SQLException {

        String sql;

        switch (campo) {
            case "nombre":
                sql = "UPDATE Cliente SET nombre=? WHERE id_cliente=?";
                break;
            case "apellido_paterno":
                sql = "UPDATE Cliente SET apellido_paterno=? WHERE id_cliente=?";
                break;
            case "apellido_materno":
                sql = "UPDATE Cliente SET apellido_materno=? WHERE id_cliente=?";
                break;
            case "contrasena":
                sql = "UPDATE Cliente SET contrasena=? WHERE id_cliente=?";
                break;
            case "domicilio":
                sql = "UPDATE Cliente SET domicilio=? WHERE id_cliente=?";
                break;
            case "codigo_postal":
                sql = "UPDATE Cliente SET codigo_postal=? WHERE id_cliente=?";
                break;
            case "num_telefonico":
                sql = "UPDATE Cliente SET num_telefonico=? WHERE id_cliente=?";
                break;
            case "tarjeta_credito":
                sql = "UPDATE Cliente SET tarjeta_credito=? WHERE id_cliente=?";
                break;
            case "fecha_expiracion":
                sql = "UPDATE Cliente SET fecha_expiracion=? WHERE id_cliente=?";
                break;
            default:
                throw new SQLException("Campo inválido");
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            switch (campo) {
                case "nombre": ps.setString(1, cliente.getNombre()); break;
                case "apellido_paterno": ps.setString(1, cliente.getApellido_paterno()); break;
                case "apellido_materno": ps.setString(1, cliente.getApellido_materno()); break;
                case "contrasena": ps.setString(1, cliente.getContrasena()); break;
                case "domicilio": ps.setString(1, cliente.getDomicilio()); break;
                case "codigo_postal": ps.setString(1, cliente.getCodigo_postal()); break;
                case "num_telefonico": ps.setString(1, cliente.getNum_telefonico()); break;
                case "tarjeta_credito": ps.setString(1, cliente.getTarjeta_credito()); break;
                case "fecha_expiracion": ps.setString(1, cliente.getFecha_expiracion()); break;
            }

            ps.setInt(2, cliente.getId_cliente());
            ps.executeUpdate();
        }
    }
}
