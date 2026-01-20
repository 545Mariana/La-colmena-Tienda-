package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

@WebServlet(
    name = "MisPedidos",
    urlPatterns = {"/MisPedidos"}
)
public class MisPedidosServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DataSource dataSource;
    
    @Override
    public void init() throws ServletException {
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:/comp/env");
            dataSource = (DataSource) envContext.lookup("jdbc/TestDS");
        } catch (Exception e) {
            throw new ServletException("Error al inicializar el DataSource", e);
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar si el cliente está en sesión
   
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("id_cliente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Obtener ID del cliente desde la sesión
        int idCliente = (int) session.getAttribute("id_cliente");
        
        try {
            List<Pedido> pedidos = obtenerPedidosCliente(idCliente);
            double totalGastado = calcularTotalGastadoCliente(idCliente);
            
            request.setAttribute("pedidos", pedidos);
            request.setAttribute("totalGastado", totalGastado);
            request.setAttribute("totalPedidos", pedidos.size());
            
            // Contar pedidos por estado
            long entregados = pedidos.stream()
                .filter(p -> p.getFechaEntrega() != null && !p.getFechaEntrega().isEmpty())
                .count();
            request.setAttribute("pedidosEntregados", entregados);
            
            request.getRequestDispatcher("/misPedidos.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?error=Error+al+cargar+pedidos");
        }
    }
    
    private List<Pedido> obtenerPedidosCliente(int idCliente) throws SQLException {
        List<Pedido> pedidos = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dataSource.getConnection();
            String sql = "SELECT " +
                        "p.id_pedido, " +
                        "p.fecha_pedido, " +
                        "p.fecha_envio, " +
                        "p.fecha_entrega, " +
                        "COALESCE(SUM(dp.total_articulo), 0) as total " +
                        "FROM Pedido p " +
                        "LEFT JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido " +
                        "WHERE p.id_cliente = ? " +
                        "GROUP BY p.id_pedido, p.fecha_pedido, p.fecha_envio, p.fecha_entrega " +
                        "ORDER BY p.fecha_pedido DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idCliente);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Pedido pedido = new Pedido();
                pedido.setIdPedido(rs.getInt("id_pedido"));
                pedido.setFechaPedido(rs.getString("fecha_pedido"));
                pedido.setFechaEnvio(rs.getString("fecha_envio"));
                pedido.setFechaEntrega(rs.getString("fecha_entrega"));
                pedido.setTotal(rs.getDouble("total"));
                
                // Obtener detalles del pedido
                pedido.setDetalles(obtenerDetallesPedido(pedido.getIdPedido()));
                
                pedidos.add(pedido);
            }
            
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return pedidos;
    }
    
    private List<DetallePedido> obtenerDetallesPedido(int idPedido) throws SQLException {
        List<DetallePedido> detalles = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dataSource.getConnection();
            String sql = "SELECT " +
                        "dp.id_detalle, " +
                        "dp.id_producto, " +
                        "dp.cantidad, " +
                        "dp.total_articulo, " +
                        "p.nombre_producto, " +
                        "p.precio_articulo " +
                        "FROM DetallePedido dp " +
                        "JOIN Producto p ON dp.id_producto = p.id_producto " +
                        "WHERE dp.id_pedido = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idPedido);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                DetallePedido detalle = new DetallePedido();
                detalle.setIdDetalle(rs.getInt("id_detalle"));
                detalle.setIdProducto(rs.getInt("id_producto"));
                detalle.setCantidad(rs.getInt("cantidad"));
                detalle.setTotalArticulo(rs.getDouble("total_articulo"));
                detalle.setNombreProducto(rs.getString("nombre_producto"));
                detalle.setPrecioUnitario(rs.getDouble("precio_articulo"));
                
                detalles.add(detalle);
            }
            
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return detalles;
    }
    
    private double calcularTotalGastadoCliente(int idCliente) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        double total = 0;
        
        try {
            conn = dataSource.getConnection();
            String sql = "SELECT COALESCE(SUM(dp.total_articulo), 0) as total_gastado " +
                        "FROM Pedido p " +
                        "JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido " +
                        "WHERE p.id_cliente = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idCliente);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                total = rs.getDouble("total_gastado");
            }
            
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        
        return total;
    }
    
    // Clase interna Pedido
    public static class Pedido {
        private int idPedido;
        private String fechaPedido;
        private String fechaEnvio;
        private String fechaEntrega;
        private double total;
        private List<DetallePedido> detalles;
        
        public Pedido() {
            detalles = new ArrayList<>();
        }
        
        // Getters y Setters
        public int getIdPedido() { return idPedido; }
        public void setIdPedido(int idPedido) { this.idPedido = idPedido; }
        
        public String getFechaPedido() { return fechaPedido; }
        public void setFechaPedido(String fechaPedido) { this.fechaPedido = fechaPedido; }
        
        public String getFechaEnvio() { return fechaEnvio; }
        public void setFechaEnvio(String fechaEnvio) { this.fechaEnvio = fechaEnvio; }
        
        public String getFechaEntrega() { return fechaEntrega; }
        public void setFechaEntrega(String fechaEntrega) { this.fechaEntrega = fechaEntrega; }
        
        public double getTotal() { return total; }
        public void setTotal(double total) { this.total = total; }
        
        public List<DetallePedido> getDetalles() { return detalles; }
        public void setDetalles(List<DetallePedido> detalles) { this.detalles = detalles; }
        
        // Métodos auxiliares
        public String getEstado() {
            if (fechaEntrega != null && !fechaEntrega.isEmpty()) {
                return "Entregado";
            } else if (fechaEnvio != null && !fechaEnvio.isEmpty()) {
                return "En camino";
            } else {
                return "En proceso";
            }
        }
        
        public String getEstadoClass() {
            if (fechaEntrega != null && !fechaEntrega.isEmpty()) {
                return "entregado";
            } else if (fechaEnvio != null && !fechaEnvio.isEmpty()) {
                return "en-camino";
            } else {
                return "en-proceso";
            }
        }
    }
    
    // Clase interna DetallePedido
    public static class DetallePedido {
        private int idDetalle;
        private int idProducto;
        private int cantidad;
        private double totalArticulo;
        private String nombreProducto;
        private double precioUnitario;
        
        // Getters y Setters
        public int getIdDetalle() { return idDetalle; }
        public void setIdDetalle(int idDetalle) { this.idDetalle = idDetalle; }
        
        public int getIdProducto() { return idProducto; }
        public void setIdProducto(int idProducto) { this.idProducto = idProducto; }
        
        public int getCantidad() { return cantidad; }
        public void setCantidad(int cantidad) { this.cantidad = cantidad; }
        
        public double getTotalArticulo() { return totalArticulo; }
        public void setTotalArticulo(double totalArticulo) { this.totalArticulo = totalArticulo; }
        
        public String getNombreProducto() { return nombreProducto; }
        public void setNombreProducto(String nombreProducto) { this.nombreProducto = nombreProducto; }
        
        public double getPrecioUnitario() { return precioUnitario; }
        public void setPrecioUnitario(double precioUnitario) { this.precioUnitario = precioUnitario; }
    }
}