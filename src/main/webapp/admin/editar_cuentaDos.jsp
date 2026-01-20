<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<!-- 
    Si entras directo a este JSP y no vienen datos,
    se reenvía al servlet para ejecutar doGet().
    Cuando regrese, ya existirá requestScope.clientes y no reenvía otra vez.
-->
<c:if test="${empty requestScope.clientes}">
    <jsp:forward page="/editar_cuentaDos" />
</c:if>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="Author" content="Alfa Buena Maravilla Onda Escuadron Lobo">
<title>Actualizar Clientes</title>
</head>
<body>

<h2 align="center">Catálogo de Clientes</h2>

<table align="center" border="1" cellpadding="6" cellspacing="0" width="800">
    <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Apellido paterno</th>
        <th>Apellido materno</th>
        <th>Editar</th>
    </tr>

    <c:forEach var="c" items="${clientes}">
        <tr>
            <td>${c.id_cliente}</td>
            <td>${c.nombre}</td>
            <td>${c.apellido_paterno}</td>
            <td>${c.apellido_materno}</td>
            <td align="center">
                <a href="${pageContext.request.contextPath}/editar_cuenta?id_cliente=${c.id_cliente}">
                    Editar
                </a>
            </td>
        </tr>
    </c:forEach>

    <!-- Mensaje por si no hay clientes -->
    <c:if test="${empty clientes}">
        <tr>
            <td colspan="5" align="center">No hay clientes registrados.</td>
        </tr>
    </c:if>
</table>

<br>
<div align="center">
    <a href="${pageContext.request.contextPath}/admin/indexAdmin.jsp">
        Regresar a administración
    </a>
</div>

<!-- Mensajes (igual formato que tu ejemplo) -->
<c:if test="${param.msg == 'ok'}">
    <p align="center" style="color:green;">✅ Campo actualizado</p>
</c:if>
<c:if test="${param.msg == 'error'}">
    <p align="center" style="color:red;">❌ No se pudo actualizar</p>
</c:if>

</body>
</html>
