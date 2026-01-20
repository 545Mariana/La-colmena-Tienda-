package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import javax.servlet.ServletException;
import javax.servlet.http.*;

/**
 * @author Usuario
 */

public class carritoServlet extends HttpServlet {
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

    // mostrar carrito
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_cliente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Map<Integer, Integer> carrito = getOrCreateCart(session);

        // mostrar cuadno no tiene nad a el carro
        if (carrito.isEmpty()) {
            request.setAttribute("items", Collections.emptyList());
            request.setAttribute("total", 0);
            request.getRequestDispatcher("/carrito.jsp").forward(request, response);
            return;
        }

        // traer los dtao sde la base datos 
        List<CartItem> items = new ArrayList<>();
        int total = 0;

        StringBuilder in = new StringBuilder();
        for (int i = 0; i < carrito.size(); i++) {
            if (i > 0) in.append(",");
            in.append("?");
        }

        String sql = "SELECT id_producto, nombre_producto, precio_articulo "
                   + "FROM producto WHERE id_producto IN (" + in + ")";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = 1;
            for (Integer idProd : carrito.keySet()) {
                ps.setInt(idx++, idProd);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id_producto = rs.getInt("id_producto");
                    String nombre = rs.getString("nombre_producto");
                    int precio = rs.getInt("precio_articulo");

                    int cantidad = carrito.getOrDefault(id_producto, 1);
                    int subtotal = precio * cantidad;
                    total += subtotal;

                    items.add(new CartItem(id_producto, nombre, precio, cantidad, subtotal));
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("items", items);
        request.setAttribute("total", total);
        request.getRequestDispatcher("/carrito.jsp").forward(request, response);
    }

    // acciones del carrito
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_cliente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Map<Integer, Integer> carrito = getOrCreateCart(session);

        String action = request.getParameter("action");
        if (action == null) action = "";

        int id_producto = parseInt(request.getParameter("id_producto"), 0);

        switch (action) {
            case "add": {
                if (id_producto > 0) {
                    int cant = carrito.getOrDefault(id_producto, 0);
                    carrito.put(id_producto, cant + 1);
                }
                response.sendRedirect(request.getContextPath() + "/carrito?msg=added");
                return;
            }

            case "update": {
                int cantidad = parseInt(request.getParameter("cantidad"), 1);
                if (id_producto > 0) {
                    if (cantidad <= 0) carrito.remove(id_producto);
                    else carrito.put(id_producto, cantidad);
                }
                response.sendRedirect(request.getContextPath() + "/carrito?msg=updated");
                return;
            }

            case "remove": {
                if (id_producto > 0) carrito.remove(id_producto);
                response.sendRedirect(request.getContextPath() + "/carrito?msg=removed");
                return;
            }

            case "clear": {
                carrito.clear();
                response.sendRedirect(request.getContextPath() + "/carrito");
                return;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/carrito");
        }
    }

 // obtiene el carrito de la sesión si no hay se crea
    private Map<Integer, Integer> getOrCreateCart(HttpSession session) {
        Object obj = session.getAttribute("carrito");
        if (obj instanceof Map) {
            return (Map<Integer, Integer>) obj;
        }
        Map<Integer, Integer> nuevo = new LinkedHashMap<>();
        session.setAttribute("carrito", nuevo);
        return nuevo;
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    // Item para el JSP
    public static class CartItem {
        private final int id_producto;
        private final String nombre;
        private final int precio;
        private final int cantidad;
        private final int subtotal;

        public CartItem(int id_producto, String nombre, int precio, int cantidad, int subtotal) {
            this.id_producto = id_producto;
            this.nombre = nombre;
            this.precio = precio;
            this.cantidad = cantidad;
            this.subtotal = subtotal;
        }

        public int getId_producto() { return id_producto; }
        public String getNombre() { return nombre; }
        public int getPrecio() { return precio; }
        public int getCantidad() { return cantidad; }
        public int getSubtotal() { return subtotal; }
    }
}
