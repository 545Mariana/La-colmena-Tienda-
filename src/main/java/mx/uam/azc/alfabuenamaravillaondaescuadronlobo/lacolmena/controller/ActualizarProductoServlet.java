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
   name = "ActualizarProducto",
   urlPatterns = {"/ActualizarProducto"}
)
public class ActualizarProductoServlet extends HttpServlet {
   private static final long serialVersionUID = 1L;

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      this.log("Actualizando Producto");

      try {
    	 request.setCharacterEncoding("UTF-8");
         response.setCharacterEncoding("UTF-8");
         this.actualizarProducto(request, response);
      } catch (Exception e) {
         throw new ServletException(e);
      }

      String base = request.getContextPath();
      response.sendRedirect(base + "/admin/agregar_producto.jsp");
   }

   private void actualizarProducto(HttpServletRequest request, HttpServletResponse response) throws NamingException, SQLException {
      // Obtener parámetros
      String idProductoStr = request.getParameter("id_producto");
      String nombre = request.getParameter("nombre_producto");
      String tipo = request.getParameter("tipo");
      String precioStr = request.getParameter("precio_articulo");
      String idInventarioStr = request.getParameter("id_inventario");
      String cantidadStr = request.getParameter("cantidad"); // NUEVO: stock editable
      
      Context context = new InitialContext();
      DataSource source = (DataSource)context.lookup("java:comp/env/jdbc/TestDS");
      Connection connection = source.getConnection();

      try {
         // Convertir valores
         int idProducto = Integer.parseInt(idProductoStr);
         float precio = Float.parseFloat(precioStr);
         int idInventario = Integer.parseInt(idInventarioStr);
         int cantidad = Integer.parseInt(cantidadStr);
         
         // Actualizar producto Y cantidad del inventario
         this.actualizarProducto(connection, idProducto, nombre, tipo, precio, idInventario, cantidad);
         
      } finally {
         connection.close();
      }
   }

   private void actualizarProducto(Connection connection, int idProducto, String nombre, 
                                   String tipo, float precio, int idInventario, int cantidad) 
                                   throws SQLException {
      
      // PRIMERO: Actualizar la cantidad en la tabla inventario
      PreparedStatement stmtInventario = connection.prepareStatement(
          "UPDATE inventario SET cantidad = ? WHERE id_inventario = ?"
      );
      
      try {
         stmtInventario.setInt(1, cantidad);
         stmtInventario.setInt(2, idInventario);
         stmtInventario.executeUpdate();
         
      } finally {
         stmtInventario.close();
      }
      
      // SEGUNDO: Actualizar el producto
      PreparedStatement stmtProducto = connection.prepareStatement(
          "UPDATE producto SET nombre_producto = ?, tipo = ?, precio_articulo = ?, id_inventario = ? WHERE id_producto = ?"
      );
      
      try {
         stmtProducto.setString(1, nombre);
         stmtProducto.setString(2, tipo != null ? tipo : "");
         stmtProducto.setFloat(3, precio);
         stmtProducto.setInt(4, idInventario);
         stmtProducto.setInt(5, idProducto);
         stmtProducto.executeUpdate();
         
      } finally {
         stmtProducto.close();
      }
   }
}