<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="Author" content="Alfa Buena Maravilla Onda Escuadron Lobo">
<title>Editar Cuenta</title>
</head>
<body>

<h2 align="center">Editar Cuenta</h2>

<!-- con sesion de cliente activo-->
<c:if test="${not empty sessionScope.id_cliente}">

    <!-- cargar los datos del cliemte actual-->
    <sql:query var="datos" dataSource="jdbc/TestDS">
        SELECT nombre, apellido_paterno, apellido_materno, contrasena,
               domicilio, codigo_postal, num_telefonico, tarjeta_credito, fecha_expiracion
        FROM cliente
        WHERE id_cliente = ?
        <sql:param value="${sessionScope.id_cliente}" />
    </sql:query>

    <!-- -->
    <c:set var="fila" value="${datos.rows[0]}" />
    <c:set var="cargado" value="${not empty fila}" />

    <table align="center" border="0" cellpadding="1" cellspacing="10" width="900">
        <!-- nombre-->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="nombre" />
            <tr>
                <td align="right">Nombre(s):</td>
                <td><input name="valor" value="${cargado ? fila.nombre : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!-- apellidoP-->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="apellido_paterno" />
            <tr>
                <td align="right">Apellido Paterno:</td>
                <td><input name="valor" value="${cargado ? fila.apellido_paterno : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!--apellido m -->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="apellido_materno" />
            <tr>
                <td align="right">Apellido Materno:</td>
                <td><input name="valor" value="${cargado ? fila.apellido_materno : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!-- contraseña-->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="contrasena" />
            <tr>
                <td align="right">Contraseña:</td>
                <td><input name="valor" value="${cargado ? fila.contrasena : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!-- direccion-->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="domicilio" />
            <tr>
                <td align="right">Domicilio:</td>
                <td><input name="valor" value="${cargado ? fila.domicilio : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!-- codigo pos -->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="codigo_postal" />
            <tr>
                <td align="right">Código Postal:</td>
                <td><input name="valor" value="${cargado ? fila.codigo_postal : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!--numero cel -->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="num_telefonico" />
            <tr>
                <td align="right">Num. Telefónico:</td>
                <td><input name="valor" value="${cargado ? fila.num_telefonico : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!-- -->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="tarjeta_credito" />
            <tr>
                <td align="right">Tarjeta de Crédito:</td>
                <td><input name="valor" value="${cargado ? fila.tarjeta_credito : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>
        <!-- fecha de tarjeta-->
        <form method="post" action="${pageContext.request.contextPath}/editar_cuenta">
            <input type="hidden" name="id_cliente" value="${sessionScope.id_cliente}" />
            <input type="hidden" name="campo" value="fecha_expiracion" />
            <tr>
                <td align="right">Fecha de Expiración:</td>
                <td><input name="valor" value="${cargado ? fila.fecha_expiracion : ''}"></td>
                <td align="center">
                    <input value="Modificar" type="submit" ${!cargado ? "disabled" : ""}>
                </td>
            </tr>
        </form>

        <tr>
            <td align="center" colspan="3">
                <input value="Regresar" type="button" onclick="history.back();">
            </td>
        </tr>

    </table>

    <!-- mesajes en caso de tener las dos posibilidades -->
    <c:if test="${param.msg == 'ok'}">
        <p align="center" style="color:green;">actualizado</p>
    </c:if>
    <c:if test="${param.msg == 'error'}">
        <p align="center" style="color:red;">No se pudo actualizar</p>
    </c:if>

</c:if>

</body>
</html>
