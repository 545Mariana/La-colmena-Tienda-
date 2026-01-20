package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

@WebServlet(
		   name = "ActualizarPedidos",
		   urlPatterns = {"/ActualizarPedidos"}
		)
public class ActualizarPedidosServlet extends HttpServlet {
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
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String idPedidoParam = request.getParameter("id_pedido");
        
        if (idPedidoParam == null || idPedidoParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/pedidos.jsp?error=ID+de+pedido+no+válido");
            return;
        }
        
        try {
            int idPedido = Integer.parseInt(idPedidoParam);
            boolean success = false;
            String message = "";
            
            if ("marcarEnviado".equals(action)) {
                String fechaEnvio = request.getParameter("fecha_envio");
                if (fechaEnvio != null && !fechaEnvio.trim().isEmpty()) {
                    success = actualizarFechaEnvio(idPedido, fechaEnvio);
                    message = success ? "Pedido+Marcado+como+Enviado" : "Error+al+marcar+envío";
                } else {
                    message = "Fecha+de+envío+requerida";
                }
                
            } else if ("marcarEntregado".equals(action)) {
                String fechaEntrega = request.getParameter("fecha_entrega");
                if (fechaEntrega != null && !fechaEntrega.trim().isEmpty()) {
                    success = actualizarFechaEntrega(idPedido, fechaEntrega);
                    message = success ? "Pedido+Marcado+como+Entregado" : "Error+al+marcar+entrega";
                } else {
                    message = "Fecha+de+entrega+requerida";
                }
            }
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/pedidos.jsp?success=" + message);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/pedidos.jsp?error=" + message);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/pedidos.jsp?error=ID+de+pedido+inválido");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/pedidos.jsp?error=Error+interno+del+servidor");
        }
    }
    
    private boolean actualizarFechaEnvio(int idPedido, String fechaEnvio) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = dataSource.getConnection();
            String sql = "UPDATE Pedido SET fecha_envio = ? WHERE id_pedido = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fechaEnvio);
            pstmt.setInt(2, idPedido);
            
            return pstmt.executeUpdate() > 0;
            
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    private boolean actualizarFechaEntrega(int idPedido, String fechaEntrega) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = dataSource.getConnection();
            String sql = "UPDATE Pedido SET fecha_entrega = ? WHERE id_pedido = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fechaEntrega);
            pstmt.setInt(2, idPedido);
            
            return pstmt.executeUpdate() > 0;
            
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
}