package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class catalogoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DataSource ds;

    @Override
    public void init() throws ServletException {
        try {
            InitialContext ctx = new InitialContext();
            ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TestDS");
        } catch (Exception e) {
            throw new ServletException("No se pudo obtener el DataSource java:comp/env/jdbc/TestDS", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Si usas acentos con GET, ayuda:
        request.setCharacterEncoding("windows-1252");

        String nombre = request.getParameter("nombre"); // puede ser null
        String tipo   = request.getParameter("tipo");   // puede ser null
        String orden  = request.getParameter("orden");  // puede ser null

        // Armamos SQL básico + filtros opcionales
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT id_producto, nombre_producto, tipo, precio_articulo, imagen ");
        sql.append("FROM producto WHERE 1=1 ");

        List<Object> params = new ArrayList<Object>();

        if (nombre != null && !nombre.trim().isEmpty()) {
            sql.append("AND nombre_producto LIKE ? ");
            params.add("%" + nombre.trim() + "%");
        }

        if (tipo != null && !tipo.trim().isEmpty()) {
            sql.append("AND tipo = ? ");
            params.add(tipo.trim());
        }

        // Orden seguro (sin concatenar lo que mande el usuario)
        if ("precio_asc".equals(orden)) {
            sql.append("ORDER BY precio_articulo ASC ");
        } else if ("precio_desc".equals(orden)) {
            sql.append("ORDER BY precio_articulo DESC ");
        } else if ("nombre".equals(orden)) {
            sql.append("ORDER BY nombre_producto ASC ");
        } else {
            sql.append("ORDER BY id_producto ASC ");
        }

        List<Producto> productos = new ArrayList<Producto>();

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            // Setear parámetros
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Producto p = new Producto(
                            rs.getInt("id_producto"),
                            rs.getString("nombre_producto"),
                            rs.getString("tipo"),
                            rs.getInt("precio_articulo"),
                            rs.getString("imagen")
                    );
                    productos.add(p);
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("productos", productos);
        request.getRequestDispatcher("/catalogo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // catálogo normalmente es GET
    }

    // Clase simple para que el JSP pueda leer con EL: ${p.nombre_producto}, etc.
    public static class Producto {
        private int id_producto;
        private String nombre_producto;
        private String tipo;
        private int precio_articulo;
        private String imagen;

        public Producto(int id_producto, String nombre_producto, String tipo, int precio_articulo, String imagen) {
            this.id_producto = id_producto;
            this.nombre_producto = nombre_producto;
            this.tipo = tipo;
            this.precio_articulo = precio_articulo;
            this.imagen = imagen;
        }

        public int getId_producto() { return id_producto; }
        public String getNombre_producto() { return nombre_producto; }
        public String getTipo() { return tipo; }
        public int getPrecio_articulo() { return precio_articulo; }
        public String getImagen() { return imagen; }
    }
}
