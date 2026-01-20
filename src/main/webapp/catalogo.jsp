<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type"
    content="text/html; charset=windows-1252">
<title>Catálogo</title>
<link rel="stylesheet" href="css/style.css">
</head>

<body>

    <table border="0" cellpadding="0" cellspacing="0" width="800">
        <tbody>

            <tr>
                <td colspan="3" align="center" height="20"></td>
            </tr>

            <tr>
                <td class="menu" align="center" valign="top" width="150"></td>
                <td width="25"></td>

                <td align="center" valign="top" width="625">

                    <div class="instructions">Selecciona un
                        producto para ver más detalles</div> <!-- BUSCADOR -->
                    <form method="get">
                        <input type="text" name="nombre"
                            placeholder="Buscar producto"
                            value="${param.nombre}"> <input
                            type="submit" value="Buscar">
                    </form> <br> <!-- CONSULTA --> <c:choose>
                        <c:when test="${not empty param.nombre}">
                            <sql:query var="productos"
                                dataSource="jdbc/TestDS">
                    SELECT * FROM producto
                    WHERE nombre_producto LIKE ?
                    <sql:param value="%${param.nombre}%" />
                            </sql:query>
                        </c:when>

                        <c:otherwise>
                            <sql:query var="productos" dataSource="jdbc/TestDS">SELECT * FROM producto
                            </sql:query>
                        </c:otherwise>
                    </c:choose> <!-- TABLA -->
                    <table width="100%">
                        <tr class="form">
                            <td align="center"><b>Imagen</b></td>
                            <td align="center"><b>Nombre</b></td>
                            <td align="center"><b>Precio</b></td>
                            <td></td>
                        </tr>

                        <c:forEach var="p" items="${productos.rows}">
                            <tr>
                                <td align="center"><img
                                    src="${pageContext.request.contextPath}/img/${p.imagen}"
                                    width="80"
                                    alt="${p.nombre_producto}"></td>

                                <td align="center">${p.nombre_producto}</td>
                                <td align="center">$${p.precio_articulo}</td>

                                <td align="center"><c:if
                                        test="${not empty sessionScope.id_cliente}">
                                        <form
                                            action="${pageContext.request.contextPath}/carrito"
                                            method="post"
                                            style="display: inline;">
                                            <input type="hidden"
                                                name="action"
                                                value="add"> <input
                                                type="hidden"
                                                name="id_producto"
                                                value="${p.id_producto}">
                                            <input type="submit"
                                                value="Agregar al Carrito">
                                        </form>
                                    </c:if> <c:if
                                        test="${empty sessionScope.id_cliente}">
                                        <input type="button"
                                            value="Agregar al Carrito"
                                            onclick="window.location='login.jsp'">
                                    </c:if></td>
                            </tr>
                        </c:forEach>

                    </table>

                </td>
            </tr>

            <tr>
                <td colspan="3" align="center"></td>
            </tr>

        </tbody>
    </table>

</body>
</html>
