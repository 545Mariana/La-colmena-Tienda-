package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

@WebServlet(
   name = "EliminarProducto",
   urlPatterns = {"/EliminarProducto"}
)
public class EliminarProductoServlet extends HttpServlet {
   private static final long serialVersionUID = 1L;

   protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      this.log("Eliminando Producto");

      try {
         this.eliminarProducto(request, response);
      } catch (Exception e) {
         throw new ServletException(e);
      }

      response.sendRedirect(request.getContextPath() + "/admin/agregar_producto.jsp");
   }

   private void eliminarProducto(HttpServletRequest request, HttpServletResponse response) throws NamingException, SQLException {
      String idStr = request.getParameter("id");
      int idProducto = 0;
      
      if (idStr != null && !idStr.trim().isEmpty()) {
         try {
            idProducto = Integer.parseInt(idStr);
         } catch (NumberFormatException e) {
            // Manejar error si no es número válido
            return;
         }
      }
      
      Context context = new InitialContext();
      DataSource source = (DataSource)context.lookup("java:comp/env/jdbc/TestDS");
      Connection connection = source.getConnection();

      try {
         this.eliminarProducto(connection, idProducto);
      } finally {
         connection.close();
      }
   }

   private void eliminarProducto(Connection connection, int idProducto) throws SQLException {
      // PRIMERO: Obtener el id_inventario del producto
      String sqlSelect = "SELECT id_inventario FROM producto WHERE id_producto = ?";
      PreparedStatement stmtSelect = connection.prepareStatement(sqlSelect);
      
      int idInventario = 0;
      
      try {
         stmtSelect.setInt(1, idProducto);
         var rs = stmtSelect.executeQuery();
         if (rs.next()) {
            idInventario = rs.getInt("id_inventario");
         }
      } finally {
         stmtSelect.close();
      }
      
      // SEGUNDO: Eliminar el producto
      String sqlProducto = "DELETE FROM producto WHERE id_producto = ?";
      PreparedStatement stmtProducto = connection.prepareStatement(sqlProducto);
      
      try {
         stmtProducto.setInt(1, idProducto);
         stmtProducto.executeUpdate();
      } finally {
         stmtProducto.close();
      }
      
      // TERCERO: Eliminar el inventario asociado
      if (idInventario > 0) {
         String sqlInventario = "DELETE FROM inventario WHERE id_inventario = ?";
         PreparedStatement stmtInventario = connection.prepareStatement(sqlInventario);
         
         try {
            stmtInventario.setInt(1, idInventario);
            stmtInventario.executeUpdate();
         } finally {
            stmtInventario.close();
         }
      }
   }
}
