<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="Author"
    content="Alfa Buena Maravilla Onda Dinamita Escuadrón Lobo">
<title>Agregar Producto</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
    <table align="center" border="0" cellpadding="1" cellspacing="10"
        width="900">

        <!-- Formulario para agregar producto -->
        <form method="post"
            action="${pageContext.request.contextPath}/AgregarProducto">
            <tr>
                <td align="right">Nombre del producto:</td>
                <td><input type="text" name="nombre_produto"
                    id="nombre_producto" value="${param.nombre_produto}" size="40"
                    required></td>
            </tr>

            <tr>
                <td align="right">Tipo:</td>
                <td><input type="text" name="tipo" id="tipo"
                    value="${param.tipo}" size="20"></td>

            </tr>

            <tr>
                <td align="right">Precio:</td>
                <td><input type="number" step="0.01" name="precio_articulo"
                    id="precio_articulo" value="${param.precio_articulo}" required>
                </td>

            </tr>
            
            <tr>
                <td align="right">Stock:</td>
                <td><input type="text" name="stock" id="stock"
                    value="${param.stock}" size="20"></td>

            </tr>

            <tr>
                <td align="center" colspan="3"><input type="submit"
                    value="Guardar Producto"> <input type="reset"
                    value="Limpiar"> </td>
            </tr>
        </form>

        <!-- Mostrar productos existentes -->
        <tr>
            <td colspan="3">
                <hr style="margin: 20px 0;">
                <h4>Productos Existentes</h4> <%@ taglib
                    uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
                <sql:setDataSource var="conexion" dataSource="jdbc/TestDS" /> <sql:query
                    var="productos" dataSource="${conexion}">
                    SELECT 
                        p.id_producto, 
                        p.nombre_producto, 
                        p.tipo, 
                        p.precio_articulo, 
                        p.id_inventario,
                        COALESCE(i.cantidad, 0) as stock  -- COALESCE para evitar null
                    FROM producto p 
                    LEFT JOIN inventario i ON p.id_inventario = i.id_inventario
                    ORDER BY p.id_producto DESC
                    LIMIT 10
                </sql:query> 
                <c:choose>
                    <c:when test="${productos.rowCount > 0}">
                        <table border="1" cellpadding="5" cellspacing="0" width="100%">
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Tipo</th>
                                <th>Precio</th>
                                <th>Stock</th>
                                <th>Acciones</th>
                            </tr>
                            <c:forEach var="prod" items="${productos.rows}">
                                <tr>
                                    <td align="center">${prod.id_producto}</td>
                                    <td>${prod.nombre_producto}</td>
                                    <td>${prod.tipo}</td>
                                    <td align="right">$${prod.precio_articulo}</td>
                                    <td align="center">${prod.stock}</td>
                                    <td align="center">
                                        <button
                                            onclick="window.location.href='editar_producto.jsp?id_producto=${prod.id_producto}'"
                                            style="font-size: 0.8em; padding: 2px 5px;">Editar</button>
                                        <button
                                            onclick="eliminarProducto(${prod.id_producto}, '${prod.nombre_producto}')"
                                            style="font-size: 0.8em; padding: 2px 5px; background-color: #ffcccc;">
                                            Eliminar</button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p style="text-align: center; color: #666;">No hay productos
                            registrados todavía.</p>
                    </c:otherwise>
                </c:choose>
            </td>
        </tr>
    </table>

    <script>
        function eliminarProducto(id, nombre) {
            if (confirm("¿Está seguro de eliminar el producto '" + nombre + "'?\nEsta acción no se puede deshacer.")) {
                // Redirigir al servlet EliminarProducto con el ID como parámetro
                window.location.href = '../EliminarProducto?id=' + id;
            }
        }
        
        // Mostrar mensaje si se envió correctamente desde el servlet
        <c:if test="${not empty param.success}">
            alert("Producto agregado exitosamente");
        </c:if>
    </script>
</body>
</html>
