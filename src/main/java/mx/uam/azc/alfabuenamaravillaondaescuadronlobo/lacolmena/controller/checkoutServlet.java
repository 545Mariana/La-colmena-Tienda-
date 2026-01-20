package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;


import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

@WebServlet(
		   name = "checkout",
		   urlPatterns = {"/checkout"}
		)
public class checkoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private DataSource ds;
    
    @Override
    public void init() throws ServletException {
        try {
            InitialContext ctx = new InitialContext();
            ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TestDS");
        } catch (Exception e) {
            throw new ServletException("Error al iniciar la conexión de la base de datos", e);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        
        // Verificar si hay sesión activa
        if (session == null || session.getAttribute("id_cliente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=Debe+iniciar+sesión");
            return;
        }
        
        int idCliente = (Integer) session.getAttribute("id_cliente");
        
        // Obtener carrito de la sesión
        @SuppressWarnings("unchecked")
        Map<Integer, Integer> carrito = (Map<Integer, Integer>) session.getAttribute("carrito");
        
        if (carrito == null || carrito.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/carrito.jsp?msg=Carrito+vacío");
            return;
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = ds.getConnection();
            con.setAutoCommit(false); // Iniciar transacción
            
            // 1. Crear el pedido
            String sqlPedido = "INSERT INTO Pedido (fecha_pedido, id_cliente) VALUES (?, ?)";
            ps = con.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS);
            
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String fechaActual = sdf.format(new Date());
            
            ps.setString(1, fechaActual);
            ps.setInt(2, idCliente);
            ps.executeUpdate();
            
            // Obtener ID del pedido creado
            int idPedido = 0;
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                idPedido = rs.getInt(1);
            }
            rs.close();
            ps.close();
            
            if (idPedido == 0) {
                throw new Exception("No se pudo crear el pedido");
            }
            
            // 2. Insertar detalles del pedido y actualizar inventario
            double totalPedido = 0;
            
            for (Map.Entry<Integer, Integer> item : carrito.entrySet()) {
                int idProducto = item.getKey();
                int cantidad = item.getValue();
                
                // Obtener información del producto
                String sqlProducto = "SELECT precio_articulo, id_inventario FROM Producto WHERE id_producto = ?";
                ps = con.prepareStatement(sqlProducto);
                ps.setInt(1, idProducto);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    double precio = rs.getDouble("precio_articulo");
                    int idInventario = rs.getInt("id_inventario");
                    double totalItem = precio * cantidad;
                    totalPedido += totalItem;
                    
                    // Insertar detalle del pedido
                    rs.close();
                    ps.close();
                    
                    String sqlDetalle = "INSERT INTO DetallePedido (id_pedido, id_producto, cantidad, total_articulo) VALUES (?, ?, ?, ?)";
                    ps = con.prepareStatement(sqlDetalle);
                    ps.setInt(1, idPedido);
                    ps.setInt(2, idProducto);
                    ps.setInt(3, cantidad);
                    ps.setDouble(4, totalItem);
                    ps.executeUpdate();
                    ps.close();
                    
                    // Actualizar inventario
                    String sqlInventario = "UPDATE Inventario SET cantidad = cantidad - ? WHERE id_inventario = ? AND cantidad >= ?";
                    ps = con.prepareStatement(sqlInventario);
                    ps.setInt(1, cantidad);
                    ps.setInt(2, idInventario);
                    ps.setInt(3, cantidad);
                    int filasActualizadas = ps.executeUpdate();
                    ps.close();
                    
                    if (filasActualizadas == 0) {
                        throw new Exception("Stock insuficiente para el producto ID: " + idProducto);
                    }
                } else {
                    throw new Exception("Producto no encontrado: " + idProducto);
                }
            }
            
            // 3. Actualizar información de pago si se proporcionó
            String tarjetaCredito = request.getParameter("tarjeta_credito");
            String fechaExpiracion = request.getParameter("fecha_expiracion");
            String idBancoStr = request.getParameter("id_banco");
            
            if (tarjetaCredito != null && !tarjetaCredito.trim().isEmpty()) {
                String sqlActualizarCliente = "UPDATE Cliente SET tarjeta_credito = ?, fecha_expiracion = ?";
                
                if (idBancoStr != null && !idBancoStr.trim().isEmpty()) {
                    sqlActualizarCliente += ", id_banco = ?";
                }
                
                sqlActualizarCliente += " WHERE id_cliente = ?";
                
                ps = con.prepareStatement(sqlActualizarCliente);
                ps.setString(1, tarjetaCredito.replace(" ", ""));
                ps.setString(2, fechaExpiracion);
                
                int paramIndex = 3;
                if (idBancoStr != null && !idBancoStr.trim().isEmpty()) {
                    ps.setInt(paramIndex++, Integer.parseInt(idBancoStr));
                }
                
                ps.setInt(paramIndex, idCliente);
                ps.executeUpdate();
                ps.close();
            }
            
            // 4. Confirmar transacción
            con.commit();
            
            // 5. Limpiar carrito
            session.removeAttribute("carrito");
            
            // 6. Redirigir a confirmación
            response.sendRedirect(request.getContextPath() + 
                "/confirmacion.jsp?id=" + idPedido + "&total=" + totalPedido);
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + 
                "/checkout.jsp?msg=Error+al+procesar+el+pedido: " + e.getMessage());
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { 
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close(); 
                }
            } catch (Exception e) {}
        }
    }
}
