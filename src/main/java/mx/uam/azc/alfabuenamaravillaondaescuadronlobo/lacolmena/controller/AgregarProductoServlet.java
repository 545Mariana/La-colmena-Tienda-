package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
   name = "AgregarProducto",
   urlPatterns = {"/AgregarProducto"}
)
public class AgregarProductoServlet extends HttpServlet {
   private static final long serialVersionUID = 1L;

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      this.log("Agregando Nuevo Producto");

      try {
    	 request.setCharacterEncoding("UTF-8");
         response.setCharacterEncoding("UTF-8");
         this.agregarProducto(request, response);
      } catch (Exception e) {
         throw new ServletException(e);
      }

      String base = request.getContextPath();
      response.sendRedirect(base + "/admin/agregar_producto.jsp");
   }

   private void agregarProducto(HttpServletRequest request, HttpServletResponse response) throws NamingException, SQLException {
      // Obtener datos del request
	
      String nombre = this.getParameter(request, "nombre_produto");
      String tipo = this.getParameter(request, "tipo");
      String precioStr = this.getParameter(request, "precio_articulo");
      String cantidadStr = this.getParameter(request, "stock");
      
      // Convertir valores
      float precio = this.parseFloat(precioStr);
      int cantidad = this.parseInt(cantidadStr);
      
      Context context = new InitialContext();
      DataSource source = (DataSource)context.lookup("java:comp/env/jdbc/TestDS");
      Connection connection = source.getConnection();

      try {
         this.agregarProducto(connection, nombre, tipo, precio, cantidad);
      } finally {
         connection.close();
      }
   }

   private void agregarProducto(Connection connection, String nombre, String tipo, float precio, int cantidad) throws SQLException {
      // 1. Insertar en inventario (la tabla donde está la cantidad)
      String sqlInventario = "INSERT INTO inventario (cantidad) VALUES (?)";
      PreparedStatement stmtInv = connection.prepareStatement(sqlInventario, PreparedStatement.RETURN_GENERATED_KEYS);
      
      try {
         stmtInv.setInt(1, cantidad);
         stmtInv.executeUpdate();
         
         // Obtener ID generado
         ResultSet rs = stmtInv.getGeneratedKeys();
         int idInventario = 0;
         if (rs.next()) {
            idInventario = rs.getInt(1);
         }
         rs.close();
         
         // 2. Insertar en producto con referencia al inventario
         String sqlProducto = "INSERT INTO producto (nombre_producto, tipo, precio_articulo, id_inventario) VALUES (?, ?, ?, ?)";
         PreparedStatement stmtProd = connection.prepareStatement(sqlProducto);
         
         try {
            stmtProd.setString(1, nombre);
            stmtProd.setString(2, tipo != null ? tipo : "");
            stmtProd.setFloat(3, precio);
            stmtProd.setInt(4, idInventario);
            stmtProd.executeUpdate();
         } finally {
            stmtProd.close();
         }
         
      } finally {
         stmtInv.close();
      }
   }
   
   // Métodos auxiliares para manejo de parámetros (similares a getCuenta)
   private String getParameter(HttpServletRequest request, String name) {
      String value = request.getParameter(name);
      return value != null ? value.trim() : "";
   }
   
   private float parseFloat(String value) {
      if (value == null || value.trim().isEmpty()) {
         return 0.0f;
      }
      try {
         return Float.parseFloat(value.trim());
      } catch (NumberFormatException e) {
         return 0.0f;
      }
   }
   
   private int parseInt(String value) {
      if (value == null || value.trim().isEmpty()) {
         return 0;
      }
      try {
         return Integer.parseInt(value.trim());
      } catch (NumberFormatException e) {
         return 0;
      }
   }
}
