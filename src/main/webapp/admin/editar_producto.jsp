<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="content-type" content="text/html; charset=windows-1252">
    <meta name="Author" content="Alfa buena maravilla onda dinamita escuadrón lobo">
    <title>Editar Producto</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
      function cargarProducto() {
        var idProducto = document.getElementById("buscar_id").value;
        if (idProducto) {
          // Recargar la página con el parámetro id_producto
          window.location.href = "?id_producto=" + idProducto;
        }
      }
      
    </script>
  </head>

  <body>
    <table border="0" cellpadding="0" cellspacing="0" width="800">
      <tbody>
        <tr>
          <td colspan="3" align="center" height="20">
            <%-- HEADER --%>
          </td>
        </tr>

        <tr>
          <td class="menu" align="center" valign="top" width="150">
            <%-- MENU --%>
          </td>

          <td width="25"><br></td>

          <td align="center" valign="top" width="625">
            <h3>Editar Producto</h3>
            
            <!-- Mostrar mensajes -->
            <c:if test="${not empty param.actualizado}">
              <c:choose>
                <c:when test="${param.actualizado == 'true'}">
                  <div >
                    ✅ Producto actualizado correctamente
                  </div>
                </c:when>
                <c:when test="${param.actualizado == 'false'}">
                  <div>
                    ❌ Error al actualizar el producto
                  </div>
                </c:when>
              </c:choose>
            </c:if>
            
            <c:if test="${not empty param.error}">
              <div>
                ❌ Error: ${param.error}
              </div>
            </c:if>

            <!-- conexion base -->
            <sql:setDataSource var="conexion" dataSource="jdbc/TestDS"/>
            
            <!-- Obtener lista de productos para el selector -->
            <sql:query var="productos" dataSource="${conexion}">
              SELECT p.id_producto, p.nombre_producto, i.cantidad
              FROM producto p 
              LEFT JOIN inventario i ON p.id_inventario = i.id_inventario
              ORDER BY p.nombre_producto
            </sql:query>

            <!-- Formulario para seleccionar producto -->
            <div style="margin-bottom: 20px; padding: 10px; border: 1px solid #ccc; ">
              <strong>Seleccionar Producto:</strong>
              <select id="buscar_id" name="buscar_id" onchange="cargarProducto()" style="margin-left: 10px;">
                <option value="">-- Seleccione un producto --</option>
                <c:forEach var="prod" items="${productos.rows}">
                  <option value="${prod.id_producto}" 
                    ${param.id_producto == prod.id_producto ? 'selected' : ''}>
                    ${prod.id_producto} - ${prod.nombre_producto} (Stock: ${prod.cantidad})
                  </option>
                </c:forEach>
              </select>
      
            </div>

            <!-- Si hay ID de producto seleccionado, obtener sus datos -->
            <c:if test="${not empty param.id_producto}">
              <sql:query dataSource="${conexion}" var="productoActual">
                SELECT p.*, i.cantidad 
                FROM producto p 
                LEFT JOIN inventario i ON p.id_inventario = i.id_inventario
                WHERE p.id_producto = ?
                <sql:param value="${param.id_producto}" />
              </sql:query>
              
              <c:set var="prod" value="${productoActual.rows[0]}" />
            </c:if>

            <!-- Verificar si se debe mostrar formulario -->
            <c:choose>
              <c:when test="${not empty param.id_producto and empty prod}">
                <div style="color: red; font-weight: bold; margin: 10px; padding: 10px; border: 1px solid red;">
                  ❌ El producto con ID ${param.id_producto} no existe.
                </div>
              </c:when>
              
              <c:when test="${not empty prod or empty param.id_producto}">
                <!-- Formulario de edición -->
                <form method="post" action="${pageContext.request.contextPath}/ActualizarProducto" onsubmit="return validarFormulario()">
                  <input type="hidden" name="id_producto" 
                         value="${not empty prod ? prod.id_producto : ''}">
                  
                  <table border="0" cellpadding="5" cellspacing="0" width="100%">
                    <tr>
                      <td align="right" width="30%">ID del producto:</td>
                      <td width="70%">
                        <input type="text" name="id_producto_display" 
                               value="${not empty prod ? prod.id_producto : 'Nuevo'}" 
                               size="5" readonly style="background-color: #f0f0f0; width: 60px;">
                      </td>
                    </tr>
                    <tr>
                      <td align="right">Nombre del producto:</td>
                      <td>
                        <input type="text" id="nombre_producto" name="nombre_producto" 
                               value="${not empty prod ? prod.nombre_producto : ''}" 
                               size="40" required style="width: 300px;">
                      </td>
                    </tr>
                    <tr>
                      <td align="right">Tipo:</td>
                      <td>
                        <input type="text" name="tipo" 
                               value="${not empty prod ? prod.tipo : ''}" 
                               size="20" style="width: 200px;">
                      </td>
                    </tr>
                    <tr>
                      <td align="right">Precio:</td>
                      <td>
                        <input type="number" id="precio_articulo" name="precio_articulo" 
                               step="0.01" min="0.01"
                               value="${not empty prod ? prod.precio_articulo : ''}" 
                               required style="width: 120px;">
                        <span style="font-size: 0.9em; color: #666;">(MXN)</span>
                      </td>
                    </tr>
                    
                    <input type="hidden" name="id_inventario" value="${prod.id_inventario}">
                    <!-- Obtener lista de inventarios para el dropdown -->
                    <sql:query var="inventarios" dataSource="${conexion}">
                      SELECT id_inventario, cantidad FROM Inventario ORDER BY id_inventario
                    </sql:query>
                    
                  
                    
                    <tr>
                      <td align="right">Stock:</td>
                      <td>
                        <c:set var="cantidadActual" value="0" />
                        <c:if test="${not empty prod.cantidad}">
                          <c:set var="cantidadActual" value="${prod.cantidad}" />
                        </c:if>
                        
                        <input type="number" id="cantidad" name="cantidad" 
                               value="${cantidadActual}" 
                               min="0" required
                               style="width: 100px;">
                        <span style="font-size: 0.9em; color: #666;">unidades</span>
                        
                        <c:choose>
                          <c:when test="${cantidadActual > 50}">
                            <span style="color: green; margin-left: 10px;">Stock alto</span>
                          </c:when>
                          <c:when test="${cantidadActual > 0}">
                            <span style="color: orange; margin-left: 10px;">Stock medio</span>
                          </c:when>
                          <c:otherwise>
                            <span style="color: red; margin-left: 10px;"> Sin stock</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                    
                                 
                    <tr>
                      <td colspan="2" align="center" style="padding-top: 20px;">
                        <input type="submit" value="Guardar Cambios">                      
                        <c:if test="${not empty prod}">
                          <button type="button" onclick="window.location.href='agregar_producto.jsp'">
                           Nuevo Producto
                          </button>
                        </c:if>
                      </td>
                    </tr>
                  </table>
                </form>
        
              </c:when>
            </c:choose>
            
            <!-- Panel de ayuda -->
            <div style="margin-top: 30px; padding: 10px; border: 1px dashed #ccc;">
              <h4> Instrucciones:</h4>
              <ul style="margin: 5px 0; padding-left: 20px; font-size: 0.9em;">
                <li>Seleccione un producto del dropdown para editarlo</li>
                <li>Modifique cualquier campo incluyendo el stock (cantidad)</li>
                <li>El stock se actualiza en la tabla <strong>inventario</strong></li>
                <li>Los demás datos se actualizan en la tabla <strong>producto</strong></li>
                <li>Haga clic en "Nuevo Producto" para limpiar el formulario</li>
              </ul>
            </div>

          </td>
        </tr>

        <tr>
          <td colspan="3" align="center">
            <%-- FOOTER --%>
          </td>
        </tr>
      </tbody>
    </table>
  </body>
</html>
